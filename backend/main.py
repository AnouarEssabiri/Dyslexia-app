from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

import torch
import os
import time
import asyncio
import io
import numpy as np
from PIL import Image

import easyocr
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

from dotenv import load_dotenv
from groq import Groq
import logging

# ─────────────────────────────
# LOGGING (ANTI SPAM)
# ─────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(levelname)s | %(name)s | %(message)s"
)

logger = logging.getLogger("app")

logging.getLogger("easyocr").setLevel(logging.ERROR)
logging.getLogger("PIL").setLevel(logging.ERROR)
logging.getLogger("transformers").setLevel(logging.ERROR)
logging.getLogger("torch").setLevel(logging.ERROR)
logging.getLogger("uvicorn.access").setLevel(logging.WARNING)

# ─────────────────────────────
# ENV
# ─────────────────────────────
_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(_THIS_DIR, ".env"), override=True)

GROQ_API_KEY = os.environ.get("GROQ_API_KEY", "")
logger.info(f"GROQ KEY: {'OK' if GROQ_API_KEY else 'MISSING'}")

groq_client = Groq(api_key=GROQ_API_KEY) if GROQ_API_KEY else None

# ─────────────────────────────
# FASTAPI
# ─────────────────────────────
app = FastAPI(title="Dyslexia API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─────────────────────────────
# GLOBALS
# ─────────────────────────────
model = None
tokenizer = None
device = None

# ─────────────────────────────
# OCR INIT
# ─────────────────────────────
try:
    gpu = torch.cuda.is_available()
    reader_ar = easyocr.Reader(['ar', 'en'], gpu=gpu, verbose=False)
    reader_fr = easyocr.Reader(['fr', 'en'], gpu=gpu, verbose=False)
except Exception as e:
    logger.error(f"OCR init failed: {e}")
    reader_ar = None
    reader_fr = None

# ─────────────────────────────
# MODELS LOAD
# ─────────────────────────────
async def load_models():
    global model, tokenizer, device

    try:
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

        model_path = os.path.join(_THIS_DIR, "models", "best_mt5_simplifier")

        if not os.path.exists(model_path):
            logger.info("Fallback to google/mt5-small")
            model_path = "google/mt5-small"

        tokenizer = AutoTokenizer.from_pretrained(model_path, legacy=False)
        model = AutoModelForSeq2SeqLM.from_pretrained(model_path)

        model.to(device)
        model.eval()

        logger.info(f"Model loaded on {device}")

    except Exception as e:
        logger.error(f"Model load failed: {e}")

# ─────────────────────────────
# STARTUP
# ─────────────────────────────
startup_done = False

@app.on_event("startup")
async def startup_event():
    global startup_done

    if startup_done:
        return

    startup_done = True
    logger.info("Starting API...")
    asyncio.create_task(load_models())

# ─────────────────────────────
# REQUEST MODELS
# ─────────────────────────────
class SimplifyRequest(BaseModel):
    text: str
    language: str = "en"
    difficulty_level: str = "medium"

class SimplifyResponse(BaseModel):
    original: str
    simplified: str
    inference_time_ms: float
    language: str

# ─────────────────────────────
# GROQ SIMPLIFY
# ─────────────────────────────
def groq_simplify_text(text: str, level: str) -> str:
    if not groq_client:
        raise Exception("Groq not available")

    system_prompt = """
You are a dyslexia-friendly text simplifier.

Rules:
- Keep meaning
- Use simple words
- Short sentences
- No extra info
Return ONLY simplified text.
"""

    completion = groq_client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": text}
        ],
        temperature=0.3,
        max_tokens=1024,
    )

    return completion.choices[0].message.content.strip()

# ─────────────────────────────
# OCR ENDPOINT
# ─────────────────────────────
@app.post("/api/ocr")
async def ocr(file: UploadFile = File(...), language: str = "ar"):

    if reader_ar is None:
        raise HTTPException(500, "OCR not ready")

    reader = reader_fr if language == "fr" else reader_ar

    content = await file.read()
    img = Image.open(io.BytesIO(content)).convert("RGB")
    img_np = np.array(img)

    results = reader.readtext(img_np, paragraph=True)

    text = "\n\n".join([r[1] for r in results]).strip()

    return {
        "filename": file.filename,
        "text": text,
        "status": "success"
    }

# ─────────────────────────────
# SIMPLIFY ENDPOINT ⭐ (IMPORTANT)
# ─────────────────────────────
@app.post("/api/simplify", response_model=SimplifyResponse)
async def simplify(request: SimplifyRequest):

    start = time.time()
    simplified = request.text

    try:
        logger.info("[SIMPLIFY] Groq running...")
        simplified = groq_simplify_text(request.text, request.difficulty_level)
        logger.info("[SIMPLIFY] Groq success")

    except Exception as e:
        logger.error(f"[SIMPLIFY] Groq failed: {e}")

        # fallback safe
        simplified = request.text

    return SimplifyResponse(
        original=request.text,
        simplified=simplified,
        inference_time_ms=(time.time() - start) * 1000,
        language=request.language
    )

# ─────────────────────────────
# HEALTH
# ─────────────────────────────
@app.get("/")
def root():
    return {"status": "ok"}
