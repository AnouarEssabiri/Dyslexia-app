"""AI service module for text simplification."""
from app.ai.cache import InferenceCache
from app.ai.inference import get_inference_queue
from app.ai.model_loader import get_model_loader
from app.ai.prompts import get_simplification_prompt

__all__ = [
    "get_model_loader",
    "get_inference_queue",
    "get_simplification_prompt",
    "InferenceCache",
]
