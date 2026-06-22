from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import torch
import os
import re
import time
import asyncio
import io
from PIL import Image
import numpy as np
import easyocr
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

from dotenv import load_dotenv
from groq import Groq
import logging

# ─────────────────────────────
# 🔇 CLEAN LOGGING CONFIG
# ─────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s | %(name)s | %(message)s"
)
logger = logging.getLogger("app")

logging.getLogger("easyocr").setLevel(logging.ERROR)
logging.getLogger("torch").setLevel(logging.ERROR)

os.environ["EASYOCR_VERBOSE"] = "0"
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "3"
os.environ["TOKENIZERS_PARALLELISM"] = "false"

# ─────────────────────────────
# ENV
# ─────────────────────────────
_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(_THIS_DIR, ".env"), override=True)

GROQ_API_KEY = os.environ.get("GROQ_API_KEY", "")
logger.info(f"GROQ KEY: {'OK' if GROQ_API_KEY else 'MISSING'}")

groq_client = Groq(api_key=GROQ_API_KEY) if GROQ_API_KEY else None

# ─────────────────────────────
# GROQ FUNCTIONS
# ─────────────────────────────
def groq_simplify_text(text: str, level: str) -> str:
    if not groq_client:
        raise Exception("Groq not available")

    system_prompt = f"""
Simplify text for dyslexia.
- keep meaning
- no hallucination
- same language
- return only text
Level: {level}
"""

    res = groq_client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": text}
        ],
        temperature=0.3,
        max_tokens=1024
    )
    return res.choices[0].message.content.strip()


def groq_correct_ocr(text: str) -> str:
    if not groq_client:
        raise Exception("Groq not available")

    res = groq_client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {"role": "system", "content": "Fix OCR text without changing meaning."},
            {"role": "user", "content": text}
        ],
        temperature=0.1,
        max_tokens=2048
    )
    return res.choices[0].message.content.strip()

# ─────────────────────────────
# FALLBACK VOCAB
# ─────────────────────────────
SIMPLE_VOCAB_EN = {
    "cultivating": "growing",
    "comprehend": "understand",
    "significant": "important"
}

def vocab_simplify(text: str) -> str:
    words = text.split()
    return " ".join(SIMPLE_VOCAB_EN.get(w.lower(), w) for w in words)

# ─────────────────────────────
# EASY OCR
# ─────────────────────────────
try:
    gpu = torch.cuda.is_available()
    reader_ar = easyocr.Reader(['ar', 'en'], gpu=gpu)
    reader_fr = easyocr.Reader(['fr', 'en'], gpu=gpu)
except Exception as e:
    logger.info(f"OCR init error: {e}")
    reader_ar = None
    reader_fr = None

# ─────────────────────────────
# FASTAPI APP
# ─────────────────────────────
app = FastAPI(title="Dyslexia API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─────────────────────────────
# MODEL STATE
# ─────────────────────────────
model = None
tokenizer = None
device = None
STARTED = False

# ─────────────────────────────
# STARTUP (NO DUPLICATES)
# ─────────────────────────────
@app.on_event("startup")
async def startup():
    global device, STARTED

    if STARTED:
        logger.info("Startup already executed → skip")
        return

    STARTED = True

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    logger.info(f"Device: {device}")

    asyncio.create_task(load_model())


async def load_model():
    global model, tokenizer

    path = os.path.join(_THIS_DIR, "models", "best_mt5_simplifier")
    if not os.path.exists(path):
        path = "google/mt5-small"

    logger.info(f"Loading model: {path}")

    tokenizer = AutoTokenizer.from_pretrained(path)
    model = AutoModelForSeq2SeqLM.from_pretrained(path).to(device)
    model.eval()

    logger.info("Model loaded")

# ─────────────────────────────
# OCR ENDPOINT
# ─────────────────────────────
@app.post("/api/ocr")
async def ocr(file: UploadFile = File(...), language: str = "ar"):
    if not reader_ar:
        raise HTTPException(500, "OCR not ready")

    reader = reader_fr if language == "fr" else reader_ar

    img = Image.open(io.BytesIO(await file.read())).convert("RGB")
    arr = np.array(img)

    results = reader.readtext(arr, paragraph=True)
    text = "\n".join([r[1] for r in results])

    try:
        text = groq_correct_ocr(text)
    except Exception as e:
        logger.info(f"OCR Groq failed: {e}")

    return {"text": text}

# ─────────────────────────────
# SIMPLIFY
# ─────────────────────────────
@app.post("/api/simplify")
async def simplify(req: dict):
    text = req["text"]
    level = req.get("difficulty_level", "medium")

    try:
        return {"result": groq_simplify_text(text, level)}
    except Exception as e:
        logger.info(f"Groq failed: {e}")

    if model and tokenizer:
        inputs = tokenizer(text, return_tensors="pt").to(device)
        out = model.generate(**inputs, max_new_tokens=150)
        return {"result": tokenizer.decode(out[0], skip_special_tokens=True)}

    return {"result": vocab_simplify(text)}

# ─────────────────────────────
# CHAT
# ─────────────────────────────
@app.post("/api/chat")
async def chat(req: dict):
    msg = req["messages"][-1]["content"]

    try:
        return {"response": groq_simplify_text(msg, "medium")}
    except:
        return {"response": vocab_simplify(msg)}

# ─────────────────────────────
# RUN SERVER
# ─────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.environ.get("PORT", 8000))
    )
