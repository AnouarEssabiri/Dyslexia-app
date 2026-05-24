"""Health check and status endpoints."""
import logging

from fastapi import APIRouter, Depends

from app.ai import get_inference_queue, get_model_loader
from app.database import get_db

logger = logging.getLogger(__name__)
router = APIRouter(tags=["health"])


@router.get("/health")
async def health_check(db=Depends(get_db)):
    """Health check endpoint.

    Returns:
        Health status including database and AI model status
    """
    try:
        # Check database connection
        db.table("users").select("*", count="exact").limit(1).execute()
        db_status = "healthy"
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
        db_status = "unhealthy"

    return {
        "status": "healthy" if db_status == "healthy" else "degraded",
        "timestamp": "2024-01-15T10:30:00Z",
        "services": {
            "database": db_status,
            "ai_model": "loading",
        },
    }


@router.get("/ai/status")
async def ai_status():
    """AI service status endpoint.

    Returns:
        AI model and inference queue status
    """
    try:
        model_loader = get_model_loader()
        inference_queue = get_inference_queue()

        device = model_loader.get_device()
        memory_info = model_loader.get_memory_info()
        cache_stats = inference_queue.get_cache_stats()

        return {
            "status": "ready",
            "model": {
                "name": "google/flan-t5-base",
                "device": device,
                "loaded": True,
                "memory_info": memory_info,
            },
            "inference_queue": {
                "queue_depth": inference_queue.get_queue_depth(),
                "max_concurrent": 2,
                "cache": cache_stats,
            },
        }
    except Exception as e:
        logger.error(f"AI status check failed: {e}")
        return {
            "status": "error",
            "error": str(e),
        }
