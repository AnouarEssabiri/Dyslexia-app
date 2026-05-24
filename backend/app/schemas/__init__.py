"""Request/response schemas."""
from app.schemas.auth import AuthResponse, LoginRequest, SignUpRequest
from app.schemas.document import (
    DocumentCreate,
    DocumentListResponse,
    DocumentResponse,
    DocumentUpdate,
)
from app.schemas.simplification import SimplifyRequest, SimplifyResponse

__all__ = [
    "SignUpRequest",
    "LoginRequest",
    "AuthResponse",
    "SimplifyRequest",
    "SimplifyResponse",
    "DocumentCreate",
    "DocumentUpdate",
    "DocumentResponse",
    "DocumentListResponse",
]
