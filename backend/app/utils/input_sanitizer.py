"""Input sanitization and validation utilities."""
import logging
import re
from typing import Optional

logger = logging.getLogger(__name__)


def sanitize_text(text: str, max_length: int = 2000) -> str:
    """Sanitize and clean text input.

    Args:
        text: Text to sanitize
        max_length: Maximum allowed length

    Returns:
        Sanitized text

    Raises:
        ValueError: If text is invalid
    """
    if not text:
        raise ValueError("Text cannot be empty")

    # Remove leading/trailing whitespace
    text = text.strip()

    if len(text) == 0:
        raise ValueError("Text cannot be empty or whitespace only")

    # Truncate if too long
    if len(text) > max_length:
        logger.warning(f"Text truncated from {len(text)} to {max_length} characters")
        text = text[:max_length].rsplit(" ", 1)[0] + "..."

    # Remove excessive whitespace
    text = re.sub(r"\s+", " ", text)

    # Remove control characters
    text = "".join(char for char in text if char.isprintable() or char in "\n\t")

    return text


def sanitize_email(email: str) -> str:
    """Sanitize and validate email address.

    Args:
        email: Email to sanitize

    Returns:
        Sanitized email

    Raises:
        ValueError: If email is invalid
    """
    email = email.strip().lower()

    # Basic email validation
    pattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    if not re.match(pattern, email):
        raise ValueError("Invalid email address")

    return email


def sanitize_filename(filename: str, max_length: int = 255) -> str:
    """Sanitize filename.

    Args:
        filename: Filename to sanitize
        max_length: Maximum length

    Returns:
        Sanitized filename
    """
    # Remove path separators and special characters
    filename = re.sub(r"[/\\:\*\?\"|<>]", "", filename)

    # Remove leading/trailing spaces and dots
    filename = filename.strip(". ")

    # Truncate if too long
    if len(filename) > max_length:
        name, ext = filename.rsplit(".", 1) if "." in filename else (filename, "")
        filename = name[: max_length - len(ext) - 1] + "." + ext if ext else filename[:max_length]

    return filename if filename else "document"
