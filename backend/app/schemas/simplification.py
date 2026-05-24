"""Schemas for text simplification endpoints."""
from pydantic import BaseModel, Field


class SimplifyRequest(BaseModel):
    """Request to simplify text."""

    text: str = Field(..., min_length=1, max_length=2000, description="Text to simplify")
    max_length: int = Field(default=512, ge=100, le=1024, description="Maximum output length")

    class Config:
        json_schema_extra = {
            "example": {
                "text": "The quick brown fox jumps over the lazy dog.",
                "max_length": 512,
            }
        }


class SimplifyResponse(BaseModel):
    """Response with simplified text."""

    original: str = Field(..., description="Original text")
    simplified: str = Field(..., description="Simplified text")
    inference_time_ms: float = Field(..., description="Inference time in milliseconds")

    class Config:
        json_schema_extra = {
            "example": {
                "original": "The quick brown fox jumps over the lazy dog.",
                "simplified": "A fast brown fox jumps over a lazy dog.",
                "inference_time_ms": 125.5,
            }
        }
