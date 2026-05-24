"""Custom exception classes."""
from fastapi import HTTPException, status


class APIError(HTTPException):
    """Base API error class."""

    def __init__(
        self,
        status_code: int,
        detail: str,
        headers: dict = None,
    ):
        super().__init__(status_code=status_code, detail=detail, headers=headers)


class ValidationError(APIError):
    """Validation error."""

    def __init__(self, detail: str):
        super().__init__(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, detail=detail)


class AuthenticationError(APIError):
    """Authentication error."""

    def __init__(self, detail: str = "Authentication failed"):
        super().__init__(status_code=status.HTTP_401_UNAUTHORIZED, detail=detail)


class AuthorizationError(APIError):
    """Authorization error."""

    def __init__(self, detail: str = "Access denied"):
        super().__init__(status_code=status.HTTP_403_FORBIDDEN, detail=detail)


class NotFoundError(APIError):
    """Resource not found error."""

    def __init__(self, detail: str = "Resource not found"):
        super().__init__(status_code=status.HTTP_404_NOT_FOUND, detail=detail)


class ConflictError(APIError):
    """Conflict error (e.g., duplicate resource)."""

    def __init__(self, detail: str = "Resource already exists"):
        super().__init__(status_code=status.HTTP_409_CONFLICT, detail=detail)


class RateLimitError(APIError):
    """Rate limit exceeded error."""

    def __init__(self, detail: str = "Too many requests"):
        super().__init__(status_code=status.HTTP_429_TOO_MANY_REQUESTS, detail=detail)


class InternalServerError(APIError):
    """Internal server error."""

    def __init__(self, detail: str = "Internal server error"):
        super().__init__(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=detail)


class ServiceUnavailableError(APIError):
    """Service unavailable error."""

    def __init__(self, detail: str = "Service temporarily unavailable"):
        super().__init__(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=detail)


class AIServiceError(APIError):
    """AI service error."""

    def __init__(self, detail: str = "Text simplification service error"):
        super().__init__(status_code=status.HTTP_503_SERVICE_UNAVAILABLE, detail=detail)
