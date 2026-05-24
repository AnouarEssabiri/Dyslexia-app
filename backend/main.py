from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import torch
from typing import Optional
import sys
import os

# Add models directory to path
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'models'))

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
    language: str = "ar"
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

# Global model variable
model = None
tokenizer = None
device = None

@app.on_event("startup")
async def startup_event():
    """Load the ML model on startup."""
    global model, tokenizer, device
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"🚀 Starting API server on device: {device}")
    
    # Disable ML model for now - use rule-based simplification
    print("⚠️  Using rule-based simplification (ML model disabled)")
    model = None
    tokenizer = None

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint."""
    return HealthResponse(
        status="healthy",
        model_loaded=model is not None,
        version="1.0.0"
    )

@app.get("/ai/status")
async def ai_status():
    """AI model status endpoint."""
    return {
        "model_loaded": model is not None,
        "device": str(device) if device else "cpu",
        "model_type": "MUSS-Arabic" if model else None
    }

def rule_based_simplify(text: str, language: str) -> str:
    """Simple rule-based text simplification for dyslexia support."""
    # Simple word replacement dictionary for common complex words
    replacements = {
        "unable": "can't",
        "understand": "get",
        "complexity": "hardness",
        "additional": "more",
        "explanations": "help",
        "demonstrate": "show",
        "consequently": "so",
        "furthermore": "also",
        "nevertheless": "still",
        "approximately": "about",
        "significant": "big",
        "substantial": "large",
        "utilize": "use",
        "facilitate": "help",
        "implement": "do",
        "demonstrate": "show",
        "illustrate": "show",
        "fundamental": "basic",
        "essential": "needed",
        "consequently": "so",
        "furthermore": "also",
        "nevertheless": "still",
    }
    
    # Split into words
    words = text.split()
    simple_words = []
    
    for word in words:
        # Remove punctuation for lookup
        clean_word = word.lower().strip('.,!?;:')
        punctuation = word[len(clean_word):] if word != clean_word else ""
        
        # Replace if in dictionary
        if clean_word in replacements:
            simple_words.append(replacements[clean_word] + punctuation)
        else:
            simple_words.append(word)
    
    return ' '.join(simple_words)

@app.post("/api/simplify", response_model=SimplifyResponse)
async def simplify_text(request: SimplifyRequest):
    """
    Simplify text using the ML model.
    
    Args:
        request: SimplifyRequest with text, language, and control level
    
    Returns:
        SimplifyResponse with original and simplified text
    """
    import time
    
    start_time = time.time()
    
    if not model or not tokenizer:
        # Use rule-based simplification as fallback
        simplified_text = rule_based_simplify(request.text, request.language)
        inference_time = (time.time() - start_time) * 1000
        
        return SimplifyResponse(
            original=request.text,
            simplified=simplified_text,
            inference_time_ms=inference_time,
            language=request.language
        )
    
    try:
        # Add prefix for T5 model
        prefix = "simplify: "
        input_text = prefix + request.text
        
        # Tokenize input
        inputs = tokenizer(input_text, return_tensors="pt", max_length=512, truncation=True).to(device)
        
        # Generate simplified text
        with torch.no_grad():
            outputs = model.generate(
                inputs.input_ids,
                max_length=256,
                num_beams=4,
                early_stopping=True,
                temperature=0.7
            )
        
        # Decode output
        simplified_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
        
        # If model output is poor quality, use rule-based fallback
        if len(simplified_text) < 10 or simplified_text == request.text:
            simplified_text = rule_based_simplify(request.text, request.language)
        
        inference_time = (time.time() - start_time) * 1000
        
        return SimplifyResponse(
            original=request.text,
            simplified=simplified_text,
            inference_time_ms=inference_time,
            language=request.language
        )
    except Exception as e:
        print(f"Error during inference: {e}")
        # Fallback to rule-based simplification
        simplified_text = rule_based_simplify(request.text, request.language)
        inference_time = (time.time() - start_time) * 1000
        
        return SimplifyResponse(
            original=request.text,
            simplified=simplified_text,
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
