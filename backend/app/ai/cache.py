"""Response caching for inference results."""
import hashlib
import logging
from collections import OrderedDict
from typing import Optional

logger = logging.getLogger(__name__)


class InferenceCache:
    """LRU cache for inference results."""

    def __init__(self, max_size: int = 1000):
        """Initialize cache.

        Args:
            max_size: Maximum number of cached items
        """
        self.max_size = max_size
        self._cache: OrderedDict[str, str] = OrderedDict()
        self._hits = 0
        self._misses = 0

    def get_key(self, text: str) -> str:
        """Generate cache key from text.

        Args:
            text: Text to hash

        Returns:
            Cache key (hash)
        """
        # Use SHA256 for consistent hashing
        return hashlib.sha256(text.encode()).hexdigest()

    def get(self, key: str) -> Optional[str]:
        """Get cached value.

        Args:
            key: Cache key

        Returns:
            Cached result or None
        """
        if key in self._cache:
            # Move to end (LRU)
            self._cache.move_to_end(key)
            self._hits += 1
            return self._cache[key]

        self._misses += 1
        return None

    def set(self, key: str, value: str) -> None:
        """Set cached value.

        Args:
            key: Cache key
            value: Value to cache
        """
        if key in self._cache:
            # Update and move to end
            self._cache.move_to_end(key)
        else:
            # Add new item
            if len(self._cache) >= self.max_size:
                # Remove oldest item
                self._cache.popitem(last=False)
                logger.debug("Cache evicted oldest item")

        self._cache[key] = value

    def clear(self) -> None:
        """Clear all cached items."""
        self._cache.clear()
        self._hits = 0
        self._misses = 0
        logger.info("Cache cleared")

    def get_stats(self) -> dict:
        """Get cache statistics.

        Returns:
            Cache statistics dict
        """
        total_requests = self._hits + self._misses
        hit_rate = (self._hits / total_requests * 100) if total_requests > 0 else 0

        return {
            "size": len(self._cache),
            "max_size": self.max_size,
            "hits": self._hits,
            "misses": self._misses,
            "hit_rate": f"{hit_rate:.1f}%",
            "total_requests": total_requests,
        }
