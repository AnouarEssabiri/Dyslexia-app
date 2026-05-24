# Dyslexia Support Platform

A comprehensive mobile and backend solution for supporting users with dyslexia through intelligent text simplification, text-to-speech, and accessibility features.

## Project Overview

This monorepo contains:

- **Flutter Mobile App** (`flutter_app/`): iOS and Android application
- **FastAPI Backend** (`backend/`): Text simplification service with AI model

## Quick Start

### Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your Supabase credentials

# Run development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Or use Docker:

```bash
cd backend
docker-compose up
```

Backend API will be at `http://localhost:8000`
API Documentation at `http://localhost:8000/docs`

### Mobile App Setup

```bash
cd flutter_app

# Get dependencies
flutter pub get

# Update Supabase credentials in lib/config/app_config.dart

# Run on Android emulator or iOS simulator
flutter run
```

## Architecture

### Backend Architecture

**FastAPI + FLAN-T5-base**
- Async inference queue for concurrent requests
- GPU auto-detection with CPU fallback
- Response caching for performance
- Health check and status endpoints
- Input sanitization and rate limiting
- Docker containerization ready

```
backend/
├── app/ai/              # AI service layer
│   ├── model_loader.py  # GPU-aware model loading
│   ├── inference.py     # Async inference queue
│   ├── prompts.py       # Prompt engineering
│   └── cache.py         # LRU response caching
├── routes/              # API endpoints
├── schemas/             # Request/response validation
└── utils/               # Input sanitization
```

### Mobile Architecture

**Flutter + Riverpod**
- Clean Architecture: Presentation → Domain → Data
- Riverpod state management
- OpenDyslexic font for dyslexia-friendly UI
- Google ML Kit for OCR
- Supabase for auth and cloud storage
- Hive for local caching

```
flutter_app/
├── lib/
│   ├── config/          # Configuration & theme
│   ├── data/            # API & local storage
│   ├── domain/          # Business logic
│   └── presentation/    # UI screens & widgets
```

## Features

### MVP (Phase 1)

#### Core Features
- ✅ User authentication with Supabase
- ✅ Text simplification via FLAN-T5-base
- ✅ OCR text scanning from camera (image compression)
- ✅ Text-to-speech with sentence highlighting
- ✅ Dyslexia-friendly reader UI
  - OpenDyslexic font
  - Reading ruler / focus mode
  - Adjustable line height & word spacing
  - Dark mode support
  - Original & simplified text comparison
- ✅ Document management (local & cloud)
- ✅ API rate limiting and timeout handling
- ✅ Health check endpoints

#### Technology Highlights
- Singleton GPU-aware model loading
- Async inference queue with timeouts
- LRU response caching
- Input sanitization
- Debounced simplification requests
- Lazy-loaded document lists
- Image compression before OCR

### Future Enhancements (Phase 2+)

- [ ] Gamification system
- [ ] MUSS integration for multilingual support
- [ ] Multiple text simplification models
- [ ] Personalized reading profiles
- [ ] Offline mode with cached models
- [ ] Advanced analytics
- [ ] Progress tracking
- [ ] Social features

## API Endpoints

### Health & Status
```
GET  /health           - Service health check
GET  /ai/status        - AI model and inference queue status
```

### Text Simplification
```
POST /api/simplify     - Simplify text using FLAN-T5
```

### Authentication (Phase 1B)
```
POST /api/auth/signup  - User registration
POST /api/auth/login   - User login
```

### Documents (Phase 1B)
```
GET  /api/documents           - List user documents
POST /api/documents           - Create new document
GET  /api/documents/{id}      - Get document
PUT  /api/documents/{id}      - Update document
DELETE /api/documents/{id}    - Delete document
```

## Configuration

### Backend Environment Variables

```bash
# app/config.py loads from .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-key
AI_MODEL_NAME=google/flan-t5-base
AI_DEVICE=auto  # auto|cpu|cuda
RATE_LIMIT_REQUESTS=20
```

### Mobile Configuration

Update `flutter_app/lib/config/app_config.dart`:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
static const String backendUrl = 'http://your-api:8000';
```

## Development

### Running Backend Tests

```bash
cd backend
pytest
```

### Running Mobile Tests

```bash
cd flutter_app
flutter test
```

### Code Quality

**Backend**
```bash
cd backend
black app/
flake8 app/
```

**Mobile**
```bash
cd flutter_app
flutter analyze
```

## Deployment

### Backend Deployment Options

1. **Docker Compose (Development)**
   ```bash
   docker-compose up
   ```

2. **Railway, Heroku, or Cloud Run**
   - Push Docker image
   - Configure environment variables
   - Set up health checks

3. **Self-hosted**
   - Deploy with systemd or supervisor
   - Set up reverse proxy (Nginx)

### Mobile Deployment

1. **iOS**
   ```bash
   flutter build ios
   # Upload to TestFlight or App Store
   ```

2. **Android**
   ```bash
   flutter build appbundle
   flutter build apk
   # Upload to Google Play
   ```

## Documentation

- **Backend**: See `backend/README.md`
- **Mobile**: See `flutter_app/README.md`
- **API Docs**: `http://localhost:8000/docs` (Swagger UI)

## Performance Targets

- API response time: <2s (including inference)
- Model load time: <5s (first time)
- Inference latency: <1.5s per request
- OCR processing: <3s (with compression)
- Cache hit rate: 40-60%

## Security Considerations

- ✅ Input sanitization (text length, special characters)
- ✅ CORS configuration
- ✅ Rate limiting per user
- ✅ JWT token validation
- ✅ Request timeout handling
- ✅ Password hashing (Phase 1B)
- ✅ HTTPS in production

## Database Schema (Supabase PostgreSQL)

### Users Table
```sql
id: uuid (PK)
email: text (unique)
name: text
created_at: timestamp
```

### Documents Table
```sql
id: uuid (PK)
user_id: uuid (FK)
title: text
content: text
original_text: text
created_at: timestamp
updated_at: timestamp
```

### Simplifications Table (Optional)
```sql
id: uuid (PK)
user_id: uuid (FK)
original_text: text
simplified_text: text
model_version: text
created_at: timestamp
```

## Troubleshooting

### Backend Issues

1. **GPU not detected**
   ```bash
   python -c "import torch; print(torch.cuda.is_available())"
   # Set AI_DEVICE=cpu in .env
   ```

2. **Model download fails**
   - Check internet connection
   - Models cached in `~/.cache/huggingface`
   - Increase timeout in config

3. **High memory usage**
   - Use `google/flan-t5-small` model
   - Reduce cache size
   - Enable swap space

### Mobile Issues

1. **Dependencies not installing**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build errors**
   ```bash
   flutter clean
   flutter pub upgrade
   ```

3. **Supabase connection fails**
   - Verify credentials in `app_config.dart`
   - Check network connectivity
   - Review Supabase RLS policies

## Contributing

Contributions are welcome! Please:

1. Create a feature branch
2. Make your changes
3. Add tests
4. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Check existing documentation
- Review the API docs at `http://localhost:8000/docs`

## Project Timeline

### Phase 1 (MVP) - In Progress
- [x] Backend setup with AI service layer
- [x] Flutter project structure
- [ ] Authentication implementation
- [ ] Text processing screens
- [ ] Integration testing

### Phase 2 (Enhancement)
- [ ] Gamification
- [ ] MUSS integration
- [ ] Analytics
- [ ] Offline support

### Phase 3 (Scale)
- [ ] Multi-language support
- [ ] Advanced personalization
- [ ] Community features

---

**Built with Flutter, FastAPI, FLAN-T5, and Supabase**
