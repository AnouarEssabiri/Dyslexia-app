"""Text simplification endpoints."""
import logging
import time

from fastapi import APIRouter, Depends

from app.ai import get_inference_queue
from app.schemas import SimplifyRequest, SimplifyResponse
from app.utils import ValidationError, sanitize_text
from app.utils.exceptions import AIServiceError

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api", tags=["simplification"])


@router.post("/simplify")
async def simplify_text(request: SimplifyRequest) -> SimplifyResponse:
    """Simplify text using FLAN-T5 model.

    Args:
        request: SimplifyRequest with text to simplify

    Returns:
        SimplifyResponse with original and simplified text

    Raises:
        ValidationError: If text is invalid
        AIServiceError: If simplification fails
    """
    try:
        # Sanitize and validate input
        try:
            sanitized_text = sanitize_text(request.text)
        except ValueError as e:
            logger.warning(f"Invalid text: {e}")
            raise ValidationError(str(e))

        # Get inference queue
        inference_queue = get_inference_queue()

        # Run inference
        start_time = time.time()
        try:
            simplified = await inference_queue.simplify_text(
                sanitized_text,
                max_length=request.max_length,
            )
        except ValueError as e:
            logger.error(f"Inference error: {e}")
            raise AIServiceError(str(e))

        inference_time_ms = (time.time() - start_time) * 1000

        logger.info(
            f"Simplification complete: {len(sanitized_text)} -> {len(simplified)} chars "
            f"({inference_time_ms:.1f}ms)"
        )

        return SimplifyResponse(
            original=request.text,
            simplified=simplified,
            inference_time_ms=inference_time_ms,
        )

    except Exception as e:
        logger.error(f"Simplify endpoint error: {e}")
        if isinstance(e, (ValidationError, AIServiceError)):
            raise
        raise AIServiceError(f"Unexpected error: {str(e)}")
