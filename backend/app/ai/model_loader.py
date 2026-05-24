"""Model loader with GPU auto-detection and singleton pattern."""
import logging
from typing import Optional

import torch
from transformers import AutoModelForSeq2SeqLM, AutoTokenizer

from app.config import settings

logger = logging.getLogger(__name__)


class ModelLoader:
    """Singleton model loader with GPU auto-detection."""

    _instance: Optional["ModelLoader"] = None
    _model = None
    _tokenizer = None
    _device: Optional[str] = None

    def __new__(cls) -> "ModelLoader":
        """Ensure singleton pattern."""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        """Initialize model loader."""
        if self._model is None:
            self._load_model()

    def _detect_device(self) -> str:
        """Auto-detect available device (GPU or CPU)."""
        if settings.AI_DEVICE == "auto":
            if torch.cuda.is_available():
                device = "cuda"
                logger.info(f"GPU detected: {torch.cuda.get_device_name(0)}")
            else:
                device = "cpu"
                logger.info("GPU not available, using CPU")
        else:
            device = settings.AI_DEVICE
            logger.info(f"Using configured device: {device}")

        self._device = device
        return device

    def _load_model(self) -> None:
        """Load FLAN-T5 model and tokenizer (singleton)."""
        try:
            device = self._detect_device()
            logger.info(f"Loading model {settings.AI_MODEL_NAME}...")

            # Load tokenizer
            self._tokenizer = AutoTokenizer.from_pretrained(settings.AI_MODEL_NAME)

            # Load model
            self._model = AutoModelForSeq2SeqLM.from_pretrained(
                settings.AI_MODEL_NAME,
                device_map=device if device == "cuda" else None,
                torch_dtype=torch.float16 if device == "cuda" else torch.float32,
            )

            # Move to device if CPU
            if device == "cpu":
                self._model = self._model.to(device)

            self._model.eval()  # Set to evaluation mode
            logger.info(f"Model loaded successfully on {device}")

        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            raise

    def get_model(self):
        """Get loaded model."""
        if self._model is None:
            self._load_model()
        return self._model

    def get_tokenizer(self):
        """Get tokenizer."""
        if self._tokenizer is None:
            self._load_model()
        return self._tokenizer

    def get_device(self) -> str:
        """Get current device."""
        if self._device is None:
            self._detect_device()
        return self._device

    def get_memory_info(self) -> dict:
        """Get GPU/CPU memory info."""
        device = self.get_device()
        info = {"device": device}

        if device == "cuda":
            info["gpu_memory_allocated"] = torch.cuda.memory_allocated() / 1e9  # GB
            info["gpu_memory_reserved"] = torch.cuda.memory_reserved() / 1e9  # GB
            info["gpu_memory_total"] = torch.cuda.get_device_properties(0).total_memory / 1e9  # GB

        return info


# Global singleton instance
_model_loader: Optional[ModelLoader] = None


def get_model_loader() -> ModelLoader:
    """Get global model loader instance."""
    global _model_loader
    if _model_loader is None:
        _model_loader = ModelLoader()
    return _model_loader
