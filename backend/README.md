# Dyslexia Support API

FastAPI backend service for text simplification using FLAN-T5 AI model, Supabase integration, and document management.

## Features

### MVP (Phase 1)
- **Text Simplification API**: FLAN-T5-base model for readable text generation
- **AI Service Layer**: 
  - GPU auto-detection with CPU fallback
  - Async inference queue for concurrent requests
  - Response caching for performance optimization
  - Timeout handling and error recovery
- **Health Checks**: Service health and AI model status endpoints
- **Input Sanitization**: Text validation and security measures
- **Rate Limiting**: Request throttling to prevent abuse
- **CORS Configuration**: Secure cross-origin resource sharing
- **Docker Support**: Ready for containerized deployment

### Endpoints

#### Health & Status
- `GET /health` - Service health check
- `GET /ai/status` - AI model and inference queue status

#### Text Simplification
- `POST /api/simplify` - Simplify text using FLAN-T5
  ```json
  {
    "text": "The quick brown fox jumps over the lazy dog.",
    "max_length": 512
  }
  ```

#### Future Endpoints (Phase 1B+)
- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User login
- `GET /api/documents` - List user documents
- `POST /api/documents` - Create new document
- `GET /api/documents/{id}` - Get document by ID
- `PUT /api/documents/{id}` - Update document
- `DELETE /api/documents/{id}` - Delete document

## Architecture

### Project Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI application
│   ├── config.py            # Configuration settings
│   ├── database.py          # Supabase client
│   ├── ai/                  # AI service layer
│   │   ├── model_loader.py  # Singleton model loading
│   │   ├── inference.py     # Async inference queue
│   │   ├── prompts.py       # Prompt engineering
│   │   └── cache.py         # Response caching
│   ├── models/              # Database models
│   ├── routes/              # API endpoints
│   │   ├── health.py
│   │   └── simplify.py
│   ├── schemas/             # Request/response schemas
│   ├── services/            # Business logic
│   ├── middleware/          # Custom middleware
│   └── utils/               # Utilities
├── requirements.txt         # Python dependencies
├── Dockerfile              # Container image
├── docker-compose.yml      # Docker Compose setup
├── .env.example            # Environment variables template
└── README.md              # This file
```

### Technology Stack

- **Framework**: FastAPI 0.104.1
- **Server**: Uvicorn with async/await
- **Database**: Supabase (PostgreSQL)
- **AI Model**: FLAN-T5-base (Hugging Face Transformers)
- **GPU Support**: PyTorch with CUDA/CPU fallback
- **Rate Limiting**: SlowAPI middleware
- **Containerization**: Docker & Docker Compose

## Getting Started

### Prerequisites

- Python 3.11+
- pip or Poetry
- Supabase account (optional for development)
- CUDA 11.8+ (optional for GPU acceleration)

### Installation

1. **Clone the repository**
```bash
cd backend
```

2. **Create virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure environment**
```bash
cp .env.example .env
# Edit .env with your Supabase credentials
```

5. **Run development server**
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`
Documentation at `http://localhost:8000/docs`

### Docker Setup

1. **Build image**
```bash
docker build -t dyslexia-api:latest .
```

2. **Run with Docker Compose**
```bash
docker-compose up
```

The API will be available at `http://localhost:8000`

## Configuration

### Environment Variables

```bash
# FastAPI
APP_NAME=Dyslexia Support API
DEBUG=False

# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-key
SUPABASE_JWT_SECRET=your-secret

# AI Model
AI_MODEL_NAME=google/flan-t5-base
AI_DEVICE=auto  # auto|cpu|cuda
AI_INFERENCE_TIMEOUT=30

# Rate Limiting
RATE_LIMIT_ENABLED=True
RATE_LIMIT_REQUESTS=20
RATE_LIMIT_WINDOW=60

# CORS
CORS_ORIGINS=["*"]
```

## API Documentation

### Simplify Text Example

**Request:**
```bash
curl -X POST "http://localhost:8000/api/simplify" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "The comprehensive analysis of contemporary socioeconomic dynamics necessitates a multifaceted examination.",
    "max_length": 512
  }'
```

**Response:**
```json
{
  "original": "The comprehensive analysis of contemporary socioeconomic dynamics necessitates a multifaceted examination.",
  "simplified": "We need to look at many parts of today's money and society issues.",
  "inference_time_ms": 125.5
}
```

## Performance

### Benchmarks (GPU: NVIDIA RTX 3080)

- **Model Load Time**: ~5s (first time)
- **Inference Time**: 500-1500ms (typical text)
- **Cache Hit Rate**: 40-60% (depending on usage)
- **Concurrent Requests**: 2-4 (with queue)

### Optimization Tips

1. **Enable GPU**: Set `AI_DEVICE=cuda` for faster inference
2. **Adjust Queue Size**: Tune `max_concurrent` in `app/ai/inference.py`
3. **Cache Strategy**: Monitor cache hit rate in `/ai/status`
4. **Model Size**: Use `google/flan-t5-base` for balance (larger models available)

## Monitoring

### Health Checks

```bash
curl http://localhost:8000/health
curl http://localhost:8000/ai/status
```

### Docker Health Check

The container includes a built-in health check that runs every 30 seconds.

## Deployment

### Production Checklist

- [ ] Set `DEBUG=False`
- [ ] Configure Supabase with proper credentials
- [ ] Set up CORS origins properly
- [ ] Enable rate limiting
- [ ] Use GPU if available
- [ ] Set up monitoring/logging
- [ ] Configure auto-restart policies

### Deployment Options

1. **Vercel** (Serverless): Limited by timeout, not recommended for AI
2. **Railway**: Recommended for hobby projects
3. **AWS/GCP/Azure**: Full control, GPU support
4. **Self-hosted**: Docker or Kubernetes

## Testing

### Run Tests
```bash
pytest
```

### Test Coverage
```bash
pytest --cov=app
```

## Troubleshooting

### Common Issues

1. **GPU not detected**
   - Check CUDA installation: `python -c "import torch; print(torch.cuda.is_available())"`
   - Set `AI_DEVICE=cpu` to force CPU

2. **Model download fails**
   - Check internet connection
   - Increase timeout: `AI_INFERENCE_TIMEOUT=60`
   - Models cached in `~/.cache/huggingface`

3. **High inference latency**
   - Check system resources (CPU/memory)
   - Reduce concurrent queue or max_length
   - Consider larger GPU

4. **Out of memory errors**
   - Reduce `AI_CACHE_MAX_SIZE`
   - Use `google/flan-t5-small` instead of base
   - Increase system swap

## Future Enhancements

- [ ] MUSS (Multilingual Unsupervised Sentence Simplification) integration
- [ ] Multiple model support with switching
- [ ] Redis caching backend
- [ ] Advanced monitoring with Prometheus/Grafana
- [ ] WebSocket support for streaming responses
- [ ] Batch processing endpoints
- [ ] Fine-tuning support

## Documentation

- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [Hugging Face Transformers](https://huggingface.co/docs/transformers/)
- [Supabase Python](https://supabase.com/docs/reference/python/introduction)
- [PyTorch Documentation](https://pytorch.org/docs/)

## License

MIT License - see LICENSE file for details

## Support

For issues and questions, please open an issue on GitHub.
