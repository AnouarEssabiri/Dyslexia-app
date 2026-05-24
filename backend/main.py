from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import torch
import sys
import os
import time
import asyncio
from concurrent.futures import ThreadPoolExecutor
from typing import Optional
from transformers import AutoModelForSeq2SeqLM, AutoTokenizer

# Add models directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'models'))

# Import custom model classes
try:
    from model.muss_model import MUSSArabicModel, CONFIGS
    from tokenizers import Tokenizer as CustomTokenizer
    CUSTOM_MODEL_AVAILABLE = True
except ImportError:
    CUSTOM_MODEL_AVAILABLE = False
    print("Warning: Custom model classes not found in path")

app = FastAPI(title="Dyslexia Support API", version="1.0.0")

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request/Response models
class SimplifyRequest(BaseModel):
    text: str
    language: str = "en"
    control_level: float = 0.5  # 0.0 = very simple, 1.0 = less simple

class SimplifyResponse(BaseModel):
    original: str
    simplified: str
    inference_time_ms: float
    language: str

class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    version: str

# Global model variables
arabic_model = None
arabic_tokenizer = None
multilang_model = None
multilang_tokenizer = None
device = None

@app.on_event("startup")
async def startup_event():
    """Load the ML models on startup."""
    global device
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Starting API server on device: {device}")
    
    # Start model loading in background
    asyncio.create_task(load_models_background())

async def load_models_background():
    global arabic_model, arabic_tokenizer, multilang_model, multilang_tokenizer
    
    # 1. Load Multilingual Model (FLAN-T5) for English and French
    try:
        print("Loading multilingual FLAN-T5 model...")
        model_name = "google/flan-t5-small"
        multilang_tokenizer = AutoTokenizer.from_pretrained(model_name)
        multilang_model = AutoModelForSeq2SeqLM.from_pretrained(model_name).to(device)
        multilang_model.eval()
        print("Multilingual model loaded successfully")
    except Exception as e:
        print(f"Failed to load multilingual model: {e}")

    # 2. Load Custom Arabic Model
    try:
        if not CUSTOM_MODEL_AVAILABLE:
            raise Exception("Custom model classes not available")

        print("Loading custom Arabic MUSS model...")
        checkpoint_path = os.path.join(os.path.dirname(__file__), "..", "models", "checkpoints", "best_model.pt")
        tokenizer_path = os.path.join(os.path.dirname(__file__), "..", "models", "tokenizer", "arabic_bpe.json")
        
        if os.path.exists(checkpoint_path) and os.path.exists(tokenizer_path):
            arabic_tokenizer = CustomTokenizer.from_file(tokenizer_path)
            checkpoint = torch.load(checkpoint_path, map_location=device)
            # Use tiny config for best_model.pt (d_model=256)
            arabic_model = MUSSArabicModel(CONFIGS["tiny"])
            arabic_model.load_state_dict(checkpoint['model_state_dict'])
            arabic_model.to(device)
            arabic_model.eval()
            print("Custom Arabic model loaded successfully")
        else:
            print("Arabic model files not found, skipping...")
    except Exception as e:
        print(f"Failed to load custom Arabic model: {e}")

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    return HealthResponse(
        status="healthy",
        model_loaded=(multilang_model is not None or arabic_model is not None),
        version="1.0.0"
    )

def rule_based_simplify(text: str, language: str) -> str:
    """Enhanced rule-based text simplification for dyslexia support."""
    replacements = {
        "en": {
            "unable": "can't", "understand": "get", "complexity": "hardness",
            "additional": "more", "explanations": "help", "demonstrate": "show",
            "consequently": "so", "furthermore": "also", "nevertheless": "still",
            "approximately": "about", "significant": "big", "substantial": "large",
            "utilize": "use", "facilitate": "help", "implement": "do",
            "illustrate": "show", "fundamental": "basic", "essential": "needed",
            "difficult": "hard", "require": "need", "purchase": "buy",
            "observe": "watch", "terminate": "end", "commence": "start"
        },
        "ar": {
            "صعوبة": "سهولة", "استخدام": "استعمال", "معقد": "صعب", "بسيط": "سهل",
            "توضيح": "شرح", "إضافي": "أكثر", "فهم": "عرف", "بسبب": "عشان",
            "بالتالي": "عشان كذا", "كبير": "واجد", "جداً": "مرة", "تحدث": "تكلم",
            "مشكلة": "علة", "دراسة": "تعلم", "مساعدة": "فزعة", "جميل": "حلو"
        },
        "fr": {
            "complexité": "difficulté", "utiliser": "se servir de", "faciliter": "aider",
            "conséquemment": "donc", "néanmoins": "pourtant", "approximativement": "environ",
            "significatif": "important", "substantiel": "grand", "fondamental": "basique",
            "essentiel": "nécessaire", "difficile": "dur", "exiger": "vouloir",
            "commencer": "débuter", "terminer": "finir", "observer": "regarder",
            "augmenter": "monter", "diminuer": "baisser", "rapide": "vite"
        }
    }
    lang_replacements = replacements.get(language, replacements["en"])
    words = text.split()
    simple_words = []
    for word in words:
        clean_word = word.lower().strip('.,!?;:')
        punctuation = word[len(clean_word):] if word != clean_word else ""
        if clean_word in lang_replacements:
            simple_words.append(lang_replacements[clean_word] + punctuation)
        else:
            simple_words.append(word)
    return ' '.join(simple_words)

@app.post("/api/simplify", response_model=SimplifyResponse)
async def simplify_text(request: SimplifyRequest):
    """
    Simplify text using AI models or rule-based fallback.
    """
    start_time = time.time()
    simplified_text = None
    
    # 1. Try Custom Arabic Model for Arabic
    if request.language == "ar" and arabic_model and arabic_tokenizer:
        try:
            encoding = arabic_tokenizer.encode(request.text)
            src_ids = torch.tensor([encoding.ids], device=device)
            control_vec = torch.tensor([[0.8, 0.8, 0.8, 1.0]], device=device, dtype=torch.float32)
            
            simplified_ids = arabic_model.simplify(src_ids, arabic_tokenizer, control_vector=control_vec, beam_size=5)
            decoded = arabic_tokenizer.decode(simplified_ids)
            for token in ["[CLS]", "[SEP]", "[PAD]", "[MASK]"]:
                decoded = decoded.replace(token, "")
            decoded = decoded.strip()
            
            # Simple repetition check
            if decoded and len(set(decoded.split())) / len(decoded.split() + [1]) > 0.4:
                simplified_text = decoded
        except Exception as e:
            print(f"Arabic model error: {e}")

    # 2. Try Multilingual Model (FLAN-T5)
    if not simplified_text and multilang_model and multilang_tokenizer:
        try:
            # Better prompts for multilingual simplification
            if request.language == "ar":
                prompt = f"بسط هذا النص العربي: {request.text}"
            elif request.language == "fr":
                prompt = f"simplifier le texte français: {request.text}"
            else:
                prompt = f"simplify this text: {request.text}"
            
            inputs = multilang_tokenizer(prompt, return_tensors="pt", max_length=512, truncation=True).to(device)
            with torch.no_grad():
                outputs = multilang_model.generate(
                    inputs.input_ids,
                    max_length=256,
                    num_beams=5,
                    no_repeat_ngram_size=3,
                    early_stopping=True,
                    temperature=0.7,
                    do_sample=True
                )
            res = multilang_tokenizer.decode(outputs[0], skip_special_tokens=True)
            if res and res != request.text and len(res) > 5:
                simplified_text = res
        except Exception as e:
            print(f"Multilingual model error: {e}")

    # 3. Always apply rule-based as a final touch or fallback
    # If AI succeeded, we can still apply rules to its output
    current_text = simplified_text if simplified_text else request.text
    final_simplified = rule_based_simplify(current_text, request.language)
    
    # Ensure we actually returned something different if possible
    if final_simplified == request.text:
        # One more attempt at rule-based on original
        final_simplified = rule_based_simplify(request.text, request.language)
    
    inference_time = (time.time() - start_time) * 1000
    
    return SimplifyResponse(
        original=request.text,
        simplified=final_simplified,
        inference_time_ms=inference_time,
        language=request.language
    )

@app.post("/api/auth/signup")
async def auth_signup():
    """Auth signup endpoint - placeholder."""
    return {"message": "Signup endpoint - to be implemented"}

@app.post("/api/auth/login")
async def auth_login():
    """Auth login endpoint - placeholder."""
    return {"message": "Login endpoint - to be implemented"}

@app.get("/api/documents")
async def get_documents():
    """Get documents endpoint - placeholder."""
    return {"documents": []}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
