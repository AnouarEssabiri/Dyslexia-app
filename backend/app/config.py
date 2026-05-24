"""Application configuration settings."""
import os
from typing import Optional

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings from environment variables."""

    # FastAPI
    APP_NAME: str = "Dyslexia Support API"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = False
    API_PREFIX: str = "/api"

    # Supabase
    SUPABASE_URL: str
    SUPABASE_KEY: str
    SUPABASE_JWT_SECRET: str

    # AI Model
    AI_MODEL_NAME: str = "google/flan-t5-base"
    AI_DEVICE: str = "auto"  # auto, cpu, cuda
    AI_INFERENCE_TIMEOUT: int = 30  # seconds
    AI_CACHE_MAX_SIZE: int = 1000

    # Rate Limiting
    RATE_LIMIT_ENABLED: bool = True
    RATE_LIMIT_REQUESTS: int = 20  # requests per minute
    RATE_LIMIT_WINDOW: int = 60  # seconds

    # CORS
    CORS_ORIGINS: list[str] = ["*"]  # Restrict in production
    CORS_ALLOW_CREDENTIALS: bool = True
    CORS_ALLOW_METHODS: list[str] = ["*"]
    CORS_ALLOW_HEADERS: list[str] = ["*"]

    # JWT
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION_HOURS: int = 24

    # API
    API_TIMEOUT: int = 30

    class Config:
        env_file = ".env"
        case_sensitive = True


# Create global settings instance
settings = Settings()
