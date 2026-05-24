"""Supabase database client setup."""
import logging
from typing import Optional

from supabase import Client, create_client

from app.config import settings

logger = logging.getLogger(__name__)


class SupabaseDB:
    """Supabase database client wrapper."""

    _instance: Optional[Client] = None

    @classmethod
    def get_client(cls) -> Client:
        """Get or create Supabase client (singleton)."""
        if cls._instance is None:
            try:
                cls._instance = create_client(
                    supabase_url=settings.SUPABASE_URL,
                    supabase_key=settings.SUPABASE_KEY,
                )
                logger.info("Supabase client initialized")
            except Exception as e:
                logger.error(f"Failed to initialize Supabase client: {e}")
                raise
        return cls._instance

    @classmethod
    def close(cls) -> None:
        """Close database connection."""
        cls._instance = None


def get_db() -> Client:
    """Dependency for getting Supabase client in routes."""
    return SupabaseDB.get_client()
