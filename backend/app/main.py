"""FastAPI application initialization."""
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routes import health, simplify

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


def create_app() -> FastAPI:
    """Create and configure FastAPI application."""
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        description="Dyslexia Support Mobile App - Text Simplification Service",
        debug=settings.DEBUG,
    )

    # CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=settings.CORS_ALLOW_CREDENTIALS,
        allow_methods=settings.CORS_ALLOW_METHODS,
        allow_headers=settings.CORS_ALLOW_HEADERS,
    )

    # Include routers
    app.include_router(health.router)
    app.include_router(simplify.router)

    @app.on_event("startup")
    async def startup_event():
        """Initialize on startup."""
        logger.info(f"Starting {settings.APP_NAME} v{settings.APP_VERSION}")
        logger.info(f"Debug mode: {settings.DEBUG}")

        # Initialize AI model on startup
        try:
            from app.ai import get_model_loader
            model_loader = get_model_loader()
            logger.info(f"AI model loaded on {model_loader.get_device()}")
        except Exception as e:
            logger.error(f"Failed to load AI model on startup: {e}")
            # Don't fail startup, the error will be caught at first request

    @app.on_event("shutdown")
    async def shutdown_event():
        """Cleanup on shutdown."""
        logger.info(f"Shutting down {settings.APP_NAME}")

    @app.get("/")
    async def root():
        """Root endpoint."""
        return {
            "name": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "status": "running",
        }

    return app


# Create app instance
app = create_app()
