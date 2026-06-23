from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import torch
import sys
import os
import re
import time
import asyncio
from typing import Optional
import io
from PIL import Image
import numpy as np
import cv2
import easyocr
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM

# ─── Groq Integration ─────────────────────────────────────────────────────────
from dotenv import load_dotenv
from groq import Groq
import os

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

# ─── Vocabulary-level simplification fallback ─────────────────────────────────
# Used when neural model copies or hallucinates.
# Maps complex word → simpler alternative (EN / FR / AR)

SIMPLE_VOCAB_EN = {
    # Health / body
    "cultivating": "growing", "heirloom": "old-fashioned", "organic": "natural",
    "celebrates": "honors", "diverse": "many different", "culinary": "cooking",
    "traditions": "customs", "substantial": "large", "investment": "amount",
    "acquiring": "getting", "utilizing": "using", "implementing": "using",
    "subsequently": "then", "approximately": "about", "frequently": "often",
    "demonstrates": "shows", "sufficient": "enough", "mitigates": "reduces",
    "nocturnal": "night-time", "muscular": "muscle", "cognitive": "mental",
    "facilitate": "help", "commence": "start", "terminate": "end",
    "endeavor": "effort", "comprehend": "understand", "significant": "important",
    "assistance": "help", "numerous": "many", "beneficial": "helpful",
    "consequently": "so", "furthermore": "also", "nevertheless": "but",
    "regarding": "about", "indicating": "showing", "requiring": "needing",
    "consumption": "eating", "ailments": "diseases", "chronic": "long-term",
    "probability": "chance", "diminishes": "reduces", "refraining": "avoiding",
    "excessive": "too much", "drastically": "greatly", "interconnected": "linked",
    # Photography / arts / sport
    "photographing": "taking photos of", "panoramic": "wide-view",
    "garners": "wins", "prestigious": "well-known", "accolades": "awards",
    "unprecedented": "never-seen-before", "portraying": "showing",
    "renowned": "famous", "captivating": "beautiful", "exquisite": "lovely",
    "heirloom": "old-fashioned", "cultivation": "growing",
    # Science / ocean / maths
    "monitoring": "watching", "oceanic": "ocean", "fluctuations": "changes",
    "necessitates": "needs", "precise": "exact", "computations": "calculations",
    "documented": "recorded", "peer-reviewed": "expert-checked",
    "academic": "scientific", "journals": "magazines", "temperature": "heat",
    "mathematical": "math", "global": "worldwide",
    # General academic
    "perpetuating": "keeping", "exacerbates": "makes worse",
    "deterioration": "decline", "proliferation": "spread",
    "dissemination": "sharing", "culminating": "ending", "elucidates": "explains",
    "ascertain": "find out", "formulate": "create", "delineate": "describe",
    "paramount": "very important", "imperative": "necessary",
    "exacerbate": "worsen", "alleviate": "reduce", "augment": "increase",
    "diminish": "reduce", "proliferate": "spread", "encompass": "include",
    "necessitate": "require", "predicated": "based", "efficacious": "effective",
    "superfluous": "extra", "ostensibly": "apparently", "paradoxically": "oddly",
    "inherently": "naturally", "fundamentally": "basically",
    "contemporary": "modern", "interpersonal": "between people",
    "isolation": "loneliness", "reinforce": "strengthen", "prevention": "stopping",
    "modern": "today's", "society": "world", "elderly": "old people",
    "financial": "money", "emotional": "feelings",
}

SIMPLE_VOCAB_FR = {
    "maintenir": "garder", "appropriée": "bonne", "fréquemment": "souvent",
    "améliore": "aide", "cognitive": "mentale", "hygiène": "propreté",
    "dentaire": "des dents", "réduction": "baisse", "conséquences": "effets",
    "nécessite": "a besoin", "investissement": "effort", "considérable": "grand",
    "utilisant": "en utilisant", "interpersonnelles": "entre personnes",
    "contemporaine": "moderne", "isolement": "solitude", "renforce": "aide",
    "profond": "grand", "prévenir": "éviter", "défavorisés": "pauvres",
    "fournir": "donner", "soutien": "aide", "financier": "monétaire",
    "émotionnel": "affectif", "tout": "pendant", "long": "toute",
    "âgées": "âgés", "respectueux": "poli", "renforcer": "aider",
    "interpersonnel": "entre personnes", "combattre": "lutter contre",
    "personnes": "gens", "préparer": "se préparer",
}

def _vocab_simplify(text: str, lang: str) -> str:
    """Word-by-word vocabulary substitution as a safe fallback."""
    vocab = SIMPLE_VOCAB_EN if lang == "en" else SIMPLE_VOCAB_FR if lang == "fr" else {}
    if not vocab:
        return text
    words = text.split()
    result = []
    for w in words:
        clean = re.sub(r"[^\w]", "", w).lower()
        trail = re.sub(r"[\w]", "", w)
        replacement = vocab.get(clean)
        if replacement:
            simplified = replacement.capitalize() if w[0].isupper() else replacement
            result.append(simplified + trail)
        else:
            result.append(w)
    simplified = " ".join(result)
    # If nothing changed at all, try splitting long sentences at conjunctions
    if simplified == text and len(text.split()) > 15:
        simplified = _split_long_sentence(text, lang)
    return simplified

def _split_long_sentence(text: str, lang: str) -> str:
    """Break a long sentence at conjunctions/relative clauses to make it easier to read."""
    splits_en = [" which ", " in order to ", " as documented ", " thereby ", " thus ", " because "]
    splits_fr = [" qui ", " afin de ", " pour ", " comme ", " parce que "]
    splits = splits_en if lang in ("en", "") else splits_fr if lang == "fr" else []
    for splitter in splits:
        if splitter in text:
            parts = text.split(splitter, 1)
            first  = parts[0].strip().rstrip(",")
            second = parts[1].strip().capitalize()
            return f"{first}. {second}."
    return text

def _first_content_word(text: str) -> str:
    stop = {"the","a","an","to","of","and","or","in","on","at","it","its",
            "that","this","with","for","as","by","from","be","is","are","was","were"}
    for w in text.split():
        clean = w.lower().strip(".,;:!?\"'")
        if clean and clean not in stop:
            return clean
    return ""

def _faithfulness_score(original: str, generated: str) -> float:
    """
    Measures how faithful the generated text is to the original.
    Returns a value between 0 and 1.
    - Score < 0.55  → hallucination (model invented new content) → fallback
    - Score > 0.92  → copying     (model didn't simplify at all)  → fallback
    - 0.55–0.92     → good simplification zone
    """
    stop = {"the","a","an","is","are","was","were","be","to","of","and","or",
            "in","on","at","it","its","that","this","with","for","as","by",
            "from","their","they","we","you","he","she","i","my","your","our",
            "which","who","what","how","when","where","not","no","very","so",
            "du","de","la","le","les","des","en","un","une","et","ou","à",
            "qui","que","se","sa","son","ses","il","elle"}

    orig_words = {w.lower().strip(".,;:!?\"'") for w in original.split() if w.lower() not in stop}
    gen_words  = [w.lower().strip(".,;:!?\"'") for w in generated.split() if w.lower() not in stop]

    if not gen_words:
        return 0.0

    hits = sum(1 for w in gen_words if w in orig_words or any(w in o or o in w for o in orig_words))
    score = hits / len(gen_words)

    # Subject-change penalty: model invented a completely new first word (e.g. "Eating" for "Photographing")
    gen_subject  = _first_content_word(generated)
    orig_text_lc = original.lower()
    if gen_subject and gen_subject not in orig_text_lc:
        prefix = gen_subject[:4]
        if not any(prefix in o for o in orig_words):
            score *= 0.3   # heavy penalty — triggers fallback

    return score


# ─── Initialize EasyOCR readers ───────────────────────────────────────────────
try:
    gpu_available = torch.cuda.is_available()
    reader_ar = easyocr.Reader(['ar', 'en'], gpu=gpu_available)
    reader_fr = easyocr.Reader(['fr', 'en'], gpu=gpu_available)
except Exception as e:
    print(f"EasyOCR initialization error: {e}")
    try:
        reader_ar = easyocr.Reader(['ar', 'en'], gpu=False)
        reader_fr = easyocr.Reader(['fr', 'en'], gpu=False)
    except Exception:
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
    model_loaded: bool
    version: str

model     = None
tokenizer = None
device    = None

@app.on_event("startup")
async def startup_event():
    global device
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Starting API server on device: {device}")
    asyncio.create_task(load_models_background())

async def load_models_background():
    global model, tokenizer
    try:
        model_path = os.path.join(os.path.dirname(__file__), "models", "best_mt5_simplifier")
        if not os.path.exists(model_path):
            print(f"Fine-tuned model not found at {model_path}. Falling back to base google/mt5-small...")
            model_path = "google/mt5-small"
        print(f"Loading model from {model_path}...")
        tokenizer = AutoTokenizer.from_pretrained(model_path, legacy=False)
        model = AutoModelForSeq2SeqLM.from_pretrained(model_path)
        model.to(device)
        model.eval()
        print(f"✅ Model loaded successfully on {device}")
    except Exception as e:
        print(f"Failed to load model: {e}")

@app.get("/health", response_model=HealthResponse)
async def health_check():
    return HealthResponse(
        status="healthy",
        model_loaded=(model is not None),
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
        final_text = raw_text
        
        # Groq OCR Correction Primary Engine
        try:
            print("[OCR] Trying Groq OCR Correction...")
            final_text = groq_correct_ocr(raw_text)
            print("[OCR] Groq Correction successful.")
        except Exception as groq_err:
            print(f"[OCR] Groq Correction failed, using raw EasyOCR: {groq_err}")
            
        return {"filename": file.filename, "text": final_text, "status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/simplify", response_model=SimplifyResponse)
async def simplify_text(request: SimplifyRequest):
    start_time = time.time()
    simplified_text = request.text
    
    # 1. Try Groq Primary Engine
    try:
        print(f"[SIMPLIFY] Trying Groq Simplification (Level: {request.difficulty_level})...")
        simplified_text = groq_simplify_text(request.text, request.difficulty_level)
        print("[SIMPLIFY] Groq Simplification successful.")
    except Exception as groq_err:
        print(f"[SIMPLIFY] Groq Simplification failed: {groq_err}. Falling back to local mT5 model...")
        # 2. Fallback to Local mT5 Model
        if model and tokenizer:
            try:
                lang_map = {
                    "ar": "أعد كتابة هذه الجملة باستخدام كلمات سهلة وبنية أقصر مع الاحتفاظ بنفس المعنى تمامًا: ",
                    "fr": "Réécrivez cette phrase en utilisant des mots simples et une structure plus courte tout en gardant exactement le même sens: ",
                    "en": "Rewrite this sentence using easy words and shorter structure while keeping exactly the same meaning: "
                }
                prompt = lang_map.get(request.language, lang_map["en"]) + request.text
                inputs = tokenizer(
                    prompt,
                    return_tensors="pt",
                    max_length=512,
                    truncation=True,
                    padding=False
                ).to(device)

                with torch.no_grad():
                    outputs = model.generate(
                        input_ids=inputs["input_ids"],
                        attention_mask=inputs["attention_mask"],
                        max_new_tokens=150,
                        min_new_tokens=5,                 # force actual generation
                        num_beams=5,
                        no_repeat_ngram_size=4,           # no repeated phrases in output
                        encoder_no_repeat_ngram_size=4,   # KEY: blocks copying 4-grams from input
                        repetition_penalty=1.2,
                        length_penalty=0.8,               # slightly favour shorter output
                        early_stopping=True,
                        do_sample=False
                    )

                decoded = tokenizer.decode(outputs[0], skip_special_tokens=True)

                if decoded:
                    faith = _faithfulness_score(request.text, decoded)
                    print(f"[SIMPLIFY] (Local) faith={faith:.2f}  out='{decoded[:80]}'")

                    if faith < 0.55 or faith > 0.92:
                        print(f"[SIMPLIFY] (Local) Poor faithfulness ({faith:.2f}) → vocab fallback")
                        simplified_text = _vocab_simplify(request.text, request.language)
                    else:
                        simplified_text = decoded
            except Exception as e:
                print(f"[SIMPLIFY] Local model error: {e}")

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
    
    response_text = text_to_process
    
    # Use Groq purely for text simplification, no conversational memory
    try:
        print("[CHAT] Trying Groq Simplification for chat message...")
        response_text = groq_simplify_text(text_to_process, "medium")
        print("[CHAT] Groq Simplification successful.")
    except Exception as groq_err:
        print(f"[CHAT] Groq Simplification failed: {groq_err}. Falling back to local mT5 model...")
        if model and tokenizer:
            try:
                lang_map = {
                    "ar": "أعد كتابة هذه الجملة باستخدام كلمات سهلة وبنية أقصر مع الاحتفاظ بنفس المعنى تمامًا: ",
                    "fr": "Réécrivez cette phrase en utilisant des mots simples et une structure plus courte tout en gardant exactement le même sens: ",
                    "en": "Rewrite this sentence using easy words and shorter structure while keeping exactly the same meaning: "
                }
                prompt = lang_map.get(request.language, lang_map["en"]) + text_to_process
                inputs = tokenizer(
                    prompt,
                    return_tensors="pt",
                    max_length=256,
                    truncation=True
                ).to(device)
                
                with torch.no_grad():
                    outputs = model.generate(
                        **inputs,
                        max_new_tokens=150,
                        min_new_tokens=5,
                        num_beams=5,
                        no_repeat_ngram_size=4,
                        encoder_no_repeat_ngram_size=4,
                        repetition_penalty=1.2,
                        length_penalty=0.8,
                        early_stopping=True,
                        do_sample=False
                    )
                res = tokenizer.decode(outputs[0], skip_special_tokens=True)
                
                if res:
                    faith = _faithfulness_score(text_to_process, res)
                    if faith < 0.55 or faith > 0.92:
                        response_text = _vocab_simplify(text_to_process, request.language)
                    else:
                        response_text = res
            except Exception as e:
                print(f"[CHAT] Local model error: {e}")

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
