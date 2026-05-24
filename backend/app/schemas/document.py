"""Schemas for document endpoints."""
from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class DocumentCreate(BaseModel):
    """Request to create a new document."""

    title: str = Field(..., min_length=1, max_length=255, description="Document title")
    content: str = Field(..., min_length=1, max_length=10000, description="Document content")
    original_text: Optional[str] = Field(None, description="Original text before simplification")

    class Config:
        json_schema_extra = {
            "example": {
                "title": "My First Document",
                "content": "This is simplified text...",
                "original_text": "This is the original text...",
            }
        }


class DocumentUpdate(BaseModel):
    """Request to update a document."""

    title: Optional[str] = Field(None, min_length=1, max_length=255)
    content: Optional[str] = Field(None, min_length=1, max_length=10000)

    class Config:
        json_schema_extra = {
            "example": {
                "title": "Updated Document",
                "content": "Updated content...",
            }
        }


class DocumentResponse(BaseModel):
    """Document response."""

    id: str = Field(..., description="Document ID")
    user_id: str = Field(..., description="Owner user ID")
    title: str = Field(..., description="Document title")
    content: str = Field(..., description="Document content")
    original_text: Optional[str] = Field(None, description="Original text before simplification")
    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")

    class Config:
        json_schema_extra = {
            "example": {
                "id": "doc-uuid",
                "user_id": "user-uuid",
                "title": "My Document",
                "content": "Simplified text...",
                "original_text": "Original text...",
                "created_at": "2024-01-15T10:30:00Z",
                "updated_at": "2024-01-15T10:30:00Z",
            }
        }


class DocumentListResponse(BaseModel):
    """List of documents response."""

    documents: list[DocumentResponse] = Field(..., description="List of documents")
    total: int = Field(..., description="Total number of documents")
    page: int = Field(..., description="Current page number")
    page_size: int = Field(..., description="Documents per page")

    class Config:
        json_schema_extra = {
            "example": {
                "documents": [],
                "total": 0,
                "page": 1,
                "page_size": 20,
            }
        }
