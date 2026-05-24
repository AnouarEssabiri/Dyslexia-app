"""Async inference queue with timeout handling."""
import asyncio
import logging
from typing import Optional

import torch

from app.ai.cache import InferenceCache
from app.ai.model_loader import get_model_loader
from app.ai.prompts import get_simplification_prompt
from app.config import settings

logger = logging.getLogger(__name__)


class InferenceQueue:
    """Async inference queue with concurrent request handling."""

    def __init__(self, max_concurrent: int = 2):
        """Initialize inference queue.

        Args:
            max_concurrent: Maximum concurrent inference requests
        """
        self.max_concurrent = max_concurrent
        self._semaphore = asyncio.Semaphore(max_concurrent)
        self._cache = InferenceCache(max_size=settings.AI_CACHE_MAX_SIZE)

    async def simplify_text(
        self,
        text: str,
        user_id: Optional[str] = None,
        max_length: int = 512,
    ) -> str:
        """Simplify text using FLAN-T5 model.

        Args:
            text: Text to simplify
            user_id: Optional user ID for personalization
            max_length: Maximum output length

        Returns:
            Simplified text
        """
        # Check cache first
        cache_key = self._cache.get_key(text)
        cached_result = self._cache.get(cache_key)
        if cached_result:
            logger.info(f"Cache hit for text (len={len(text)})")
            return cached_result

        # Acquire semaphore to limit concurrent requests
        async with self._semaphore:
            try:
                loop = asyncio.get_event_loop()

                # Run inference in thread pool to avoid blocking
                result = await asyncio.wait_for(
                    loop.run_in_executor(
                        None,
                        self._run_inference,
                        text,
                        max_length,
                    ),
                    timeout=settings.AI_INFERENCE_TIMEOUT,
                )

                # Cache result
                self._cache.set(cache_key, result)

                return result

            except asyncio.TimeoutError:
                logger.error(f"Inference timeout for text (len={len(text)})")
                raise ValueError("Text simplification took too long. Please try shorter text.")
            except Exception as e:
                logger.error(f"Inference error: {e}")
                raise

    def _run_inference(self, text: str, max_length: int) -> str:
        """Run inference in thread pool (blocking).

        Args:
            text: Text to simplify
            max_length: Maximum output length

        Returns:
            Simplified text
        """
        try:
            loader = get_model_loader()
            model = loader.get_model()
            tokenizer = loader.get_tokenizer()
            device = loader.get_device()

            # Get prompt
            prompt = get_simplification_prompt(text)

            # Tokenize input
            inputs = tokenizer(prompt, return_tensors="pt", max_length=1024, truncation=True)
            inputs = {k: v.to(device) for k, v in inputs.items()}

            # Generate output
            with torch.no_grad():
                outputs = model.generate(
                    **inputs,
                    max_length=max_length,
                    num_beams=4,
                    early_stopping=True,
                    temperature=0.7,
                    top_p=0.9,
                )

            # Decode output
            simplified = tokenizer.decode(outputs[0], skip_special_tokens=True)

            logger.info(f"Inference complete: {len(text)} -> {len(simplified)} chars")
            return simplified

        except Exception as e:
            logger.error(f"Inference execution error: {e}")
            raise

    def get_queue_depth(self) -> int:
        """Get current queue depth (waiting requests)."""
        return self.max_concurrent - self._semaphore._value

    def get_cache_stats(self) -> dict:
        """Get cache statistics."""
        return self._cache.get_stats()

    def clear_cache(self) -> None:
        """Clear inference cache."""
        self._cache.clear()
        logger.info("Inference cache cleared")


# Global inference queue instance
_inference_queue: Optional[InferenceQueue] = None


def get_inference_queue() -> InferenceQueue:
    """Get global inference queue instance."""
    global _inference_queue
    if _inference_queue is None:
        _inference_queue = InferenceQueue(max_concurrent=2)
    return _inference_queue
