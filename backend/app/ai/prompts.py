"""FLAN-T5 prompt engineering for text simplification."""
import logging

logger = logging.getLogger(__name__)


def get_simplification_prompt(text: str) -> str:
    """Generate FLAN-T5 prompt for text simplification.

    Focus on readability improvement for dyslexic users, not simulating dyslexia.
    Preserve meaning, proper nouns, dates, and numbers.

    Args:
        text: Text to simplify

    Returns:
        Prompt for FLAN-T5 model
    """
    # FLAN-T5 prompt engineering for simplification
    prompt = f"""Simplify the following text to make it easier to read and understand. 
Use shorter sentences, simpler words, and clearer structure.
Preserve all important information, proper nouns, dates, and numbers.
Do NOT change the meaning of the text.

Text: {text}

Simplified text:"""

    return prompt


def get_summary_prompt(text: str) -> str:
    """Generate FLAN-T5 prompt for text summarization.

    Args:
        text: Text to summarize

    Returns:
        Prompt for FLAN-T5 model
    """
    prompt = f"""Summarize the following text in 2-3 sentences, preserving the main ideas:

Text: {text}

Summary:"""

    return prompt


def get_extraction_prompt(text: str, query: str) -> str:
    """Generate FLAN-T5 prompt for information extraction.

    Args:
        text: Text to extract from
        query: What to extract

    Returns:
        Prompt for FLAN-T5 model
    """
    prompt = f"""Extract the answer to the following question from the text:

Question: {query}

Text: {text}

Answer:"""

    return prompt


def validate_text_length(text: str, max_length: int = 2000) -> tuple[bool, str]:
    """Validate text length for processing.

    Args:
        text: Text to validate
        max_length: Maximum allowed length

    Returns:
        Tuple of (is_valid, error_message)
    """
    if not text or len(text.strip()) == 0:
        return False, "Text cannot be empty"

    if len(text) > max_length:
        return False, f"Text is too long. Maximum {max_length} characters allowed."

    return True, ""
