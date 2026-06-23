from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import time
from typing import Optional
import io
from PIL import Image
import numpy as np
import cv2
import easyocr

# ─── Groq Integration ─────────────────────────────────────────────────────────
from dotenv import load_dotenv
from groq import Groq

# Use abspath to guarantee we find .env regardless of CWD when uvicorn runs
_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
dotenv_path = os.path.join(_THIS_DIR, '.env')
load_dotenv(dotenv_path, override=True)

GROQ_API_KEY = os.environ.get("GROQ_API_KEY", "")
print(f"[STARTUP] GROQ_API_KEY loaded: {'YES (len=' + str(len(GROQ_API_KEY)) + ')' if GROQ_API_KEY else 'NO - KEY MISSING!'}")
groq_client = Groq(api_key=GROQ_API_KEY) if GROQ_API_KEY else None

def groq_simplify_text(text: str, level: str) -> str:
    if not groq_client:
        raise Exception(f"Groq client not initialized (API key present: {bool(GROQ_API_KEY)})")
    
    level_instructions = "Use moderate simplification. Use simpler vocabulary but preserve details."
    if level.lower() == "easy":
        level_instructions = "Use maximum simplification. Use very short sentences and very common words."
    elif level.lower() == "hard":
        level_instructions = "Use minimal simplification. Preserve most terminology but improve readability."
        
    system_prompt = f"""You are an expert text simplification assistant specialized in helping people with dyslexia.

Your task is to rewrite the text using simpler vocabulary, shorter sentences, and clearer grammar while preserving the original meaning.

Rules:
* Preserve the original meaning.
* Do not add information.
* Do not remove important information.
* Do not hallucinate.
* Preserve names, numbers, dates, and facts.
* Preserve the language of the input text.
* Return only the simplified text.
* Adapt the simplification level according to the provided difficulty setting:
  {level_instructions}"""
    
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

def groq_correct_ocr(text: str) -> str:
    if not groq_client:
        raise Exception("Groq client not initialized")
        
    system_prompt = """You are an OCR correction expert.

Your task is to repair OCR extracted text.

Rules:
* Correct spelling mistakes.
* Fix punctuation.
* Restore missing spaces.
* Repair broken words.
* Preserve the original meaning.
* Do not summarize.
* Do not simplify.
* Return only the corrected text."""

    completion = groq_client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": text}
        ],
        temperature=0.1,
        max_tokens=2048,
    )
    return completion.choices[0].message.content.strip()


# ─── Initialize EasyOCR readers ───────────────────────────────────────────────
try:
    # EasyOCR manages its own internal PyTorch setup; passing gpu=True defaults to GPU if available
    reader_ar = easyocr.Reader(['ar', 'en'], gpu=True)
    reader_fr = easyocr.Reader(['fr', 'en'], gpu=True)
except Exception as e:
    print(f"EasyOCR GPU initialization failed, falling back to CPU: {e}")
    try:
        reader_ar = easyocr.Reader(['ar', 'en'], gpu=False)
        reader_fr = easyocr.Reader(['fr', 'en'], gpu=False)
    except Exception as critical_e:
        print(f"EasyOCR critical initialization failure: {critical_e}")
        reader_ar = None
        reader_fr = None

app = FastAPI(title="Dyslexia Support API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class SimplifyRequest(BaseModel):
    text: str
    language: str = "en"
    control_level: float = 0.5
    difficulty_level: str = "medium"

class SimplifyResponse(BaseModel):
    original: str
    simplified: str
    inference_time_ms: float
    language: str

class ChatRequest(BaseModel):
    messages: list
    language: str = "en"

class ChatResponse(BaseModel):
    response: str
    inference_time_ms: float

class HealthResponse(BaseModel):
    status: str
    groq_connected: bool
    version: str

@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="healthy",
        groq_connected=(groq_client is not None),
        version="1.0.0"
    )

@app.post("/api/ocr")
async def perform_ocr(file: UploadFile = File(...), language: str = "ar"):
    if reader_ar is None or reader_fr is None:
        raise HTTPException(status_code=500, detail="OCR engine not initialized")
    reader = reader_fr if language == "fr" else reader_ar
    try:
        content = await file.read()
        image_pil = Image.open(io.BytesIO(content))
        if image_pil.mode != 'RGB':
            image_pil = image_pil.convert('RGB')
        image_np = np.array(image_pil)
        
        results = reader.readtext(
            image_np,
            paragraph=True,
            decoder='beamsearch',
            beamWidth=5,
            text_threshold=0.7,
            low_text=0.4,
            canvas_size=2560,
            mag_ratio=1.2
        )
        if not results:
            return {"filename": file.filename, "text": "", "status": "no_text_detected"}
        
        raw_text = "\n\n".join([res[1] for res in results]).strip()
        
        # Groq OCR Correction Primary Engine
        try:
            print("[OCR] Processing correction with Groq...")
            final_text = groq_correct_ocr(raw_text)
            print("[OCR] Groq Correction successful.")
        except Exception as groq_err:
            print(f"[OCR] Groq Correction failed, returning raw EasyOCR text: {groq_err}")
            final_text = raw_text
            
        return {"filename": file.filename, "text": final_text, "status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/simplify", response_model=SimplifyResponse)
async def simplify_text(request: SimplifyRequest):
    start_time = time.time()
    
    if not groq_client:
        raise HTTPException(status_code=500, detail="Groq client is not configured.")
        
    try:
        print(f"[SIMPLIFY] Requesting Groq Simplification (Level: {request.difficulty_level})...")
        simplified_text = groq_simplify_text(request.text, request.difficulty_level)
        print("[SIMPLIFY] Groq Simplification successful.")
    except Exception as groq_err:
        print(f"[SIMPLIFY] Groq Simplification failed: {groq_err}")
        raise HTTPException(status_code=500, detail=f"Simplification failed: {str(groq_err)}")

    return SimplifyResponse(
        original=request.text,
        simplified=simplified_text,
        inference_time_ms=(time.time() - start_time) * 1000,
        language=request.language
    )

@app.post("/api/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    start_time = time.time()
    text_to_process = ""
    if request.messages:
        text_to_process = request.messages[-1].get("content", "")
    
    if not groq_client:
        raise HTTPException(status_code=500, detail="Groq client is not configured.")
        
    try:
        print("[CHAT] Requesting Groq Simplification for chat message...")
        response_text = groq_simplify_text(text_to_process, "medium")
        print("[CHAT] Groq Simplification successful.")
    except Exception as groq_err:
        print(f"[CHAT] Groq Simplification failed: {groq_err}")
        raise HTTPException(status_code=500, detail=f"Chat simplification failed: {str(groq_err)}")

    inference_time = (time.time() - start_time) * 1000
    return ChatResponse(response=response_text, inference_time_ms=inference_time)

@app.post("/api/auth/signup")
async def auth_signup():
    return {"message": "Signup endpoint - to be implemented"}

@app.post("/api/auth/login")
async def auth_login():
    return {"message": "Login endpoint - to be implemented"}

@app.get("/api/documents")
async def get_documents():
    return {"documents": []}

import uvicorn

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=port
    )
