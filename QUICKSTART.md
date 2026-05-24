# Dyslexia Support Platform - Quick Start Guide

Get the Dyslexia Support Platform running in minutes with this quick start guide.

## Prerequisites

### Backend
- Python 3.11+
- Virtual environment tool (venv, Poetry, etc.)

### Mobile
- Flutter 3.13+
- Dart 3.1+
- Android Studio or Xcode (for emulator)

### Cloud Services
- Supabase account (for authentication and storage)

---

## Backend Setup (5 minutes)

### Step 1: Navigate to backend directory
```bash
cd backend
```

### Step 2: Create and activate virtual environment
```bash
python -m venv venv

# On macOS/Linux
source venv/bin/activate

# On Windows
venv\Scripts\activate
```

### Step 3: Install dependencies
```bash
pip install -r requirements.txt
```

### Step 4: Configure environment
```bash
cp .env.example .env
```

Edit `.env` and add your Supabase credentials:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-public-key
SUPABASE_JWT_SECRET=your-jwt-secret
```

### Step 5: Run development server
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

✅ **Backend running at**: `http://localhost:8000`
📚 **API Documentation**: `http://localhost:8000/docs`

### Or use Docker Compose

```bash
cd backend
docker-compose up
```

---

## Flutter Mobile App Setup (5 minutes)

### Step 1: Navigate to Flutter app directory
```bash
cd flutter_app
```

### Step 2: Get dependencies
```bash
flutter pub get
```

### Step 3: Configure Supabase

Edit `lib/config/app_config.dart`:

```dart
// Line 12-13
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

// Line 16 (update if backend is not localhost)
static const String backendUrl = 'http://localhost:8000';
```

### Step 4: Run on emulator

**Android:**
```bash
flutter run
```

**iOS:**
```bash
open -a Simulator
flutter run
```

✅ **App running on device/emulator**

---

## Test the Integration

### 1. Sign Up in the App
- Open the app
- Click "Sign Up"
- Enter email, password, and name
- Submit

### 2. Log In
- Return to login screen (or auto-logged in)
- You're now on the home page

### 3. Test Text Simplification
- Click "Paste Text" on home page
- Paste complex text
- App simplifies it using the backend AI
- View the simplified result

### 4. Check Backend Health
```bash
curl http://localhost:8000/health
curl http://localhost:8000/ai/status
```

---

## File Structure

```
dyslexia-support/
├── backend/               # FastAPI server
│   ├── app/              # Application code
│   │   ├── ai/           # FLAN-T5 AI service
│   │   ├── routes/       # API endpoints
│   │   ├── schemas/      # Data validation
│   │   └── utils/        # Utilities
│   ├── requirements.txt   # Dependencies
│   ├── Dockerfile        # Docker image
│   └── README.md         # Backend docs
│
├── flutter_app/          # Flutter mobile app
│   ├── lib/
│   │   ├── config/       # Configuration
│   │   ├── data/         # API client
│   │   └── presentation/ # UI screens
│   ├── pubspec.yaml      # Dependencies
│   └── README.md         # Mobile docs
│
├── README.md             # Main documentation
├── BUILD_SUMMARY.md      # Build details
└── QUICKSTART.md         # This file
```

---

## Common Commands

### Backend

```bash
# Development
cd backend
source venv/bin/activate
uvicorn app.main:app --reload

# Docker
docker-compose up
docker-compose down

# Health check
curl http://localhost:8000/health

# API docs
open http://localhost:8000/docs
```

### Flutter

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Clean build
flutter clean
flutter pub get
flutter run

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios
```

---

## Troubleshooting

### Backend Won't Start

**Problem**: ModuleNotFoundError
```bash
# Solution: Install dependencies
pip install -r requirements.txt
```

**Problem**: GPU not available
```bash
# Solution: Use CPU instead
# Edit .env
AI_DEVICE=cpu
```

**Problem**: Port 8000 already in use
```bash
# Solution: Use different port
uvicorn app.main:app --reload --port 8001
```

### Mobile App Won't Connect

**Problem**: Can't connect to backend
```
- Check backend is running: curl http://localhost:8000/health
- Update backend URL in lib/config/app_config.dart
- Check if backend is on same network (for mobile device)
```

**Problem**: Supabase connection fails
```
- Verify Supabase URL and key in lib/config/app_config.dart
- Check Supabase project is active
- Review Supabase RLS policies
```

**Problem**: App won't build
```bash
flutter clean
flutter pub upgrade
flutter run
```

---

## Next Steps

### Immediate (Phase 1B Continuation)
1. Set up Supabase PostgreSQL database
   - Users table
   - Documents table
2. Implement document CRUD operations
3. Add OCR camera functionality
4. Implement text-to-speech reader

### Short Term (Phase 2)
1. Add offline caching with Hive
2. Implement document organization
3. Add user progress tracking
4. Implement gamification

### Long Term (Phase 3)
1. Multi-language support
2. MUSS integration
3. Advanced personalization
4. Social/sharing features

---

## Documentation Links

- **Backend Docs**: `backend/README.md`
- **Mobile Docs**: `flutter_app/README.md`
- **Project Overview**: `README.md`
- **Implementation Plan**: `v0_plans/intuitive-build.md`
- **Build Details**: `BUILD_SUMMARY.md`
- **API Swagger UI**: `http://localhost:8000/docs`

---

## Key Endpoints

### Health & Status
```
GET http://localhost:8000/health
GET http://localhost:8000/ai/status
```

### Text Simplification
```
POST http://localhost:8000/api/simplify
Content-Type: application/json

{
  "text": "Your complex text here",
  "max_length": 512
}
```

---

## Environment Variables

### Backend (.env)
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-key
SUPABASE_JWT_SECRET=your-secret
AI_MODEL_NAME=google/flan-t5-base
AI_DEVICE=auto
```

### Mobile (lib/config/app_config.dart)
```dart
supabaseUrl = 'YOUR_SUPABASE_URL'
supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'
backendUrl = 'http://localhost:8000'
```

---

## Support

For detailed information:
- Check `README.md` for project overview
- See `backend/README.md` for backend details
- See `flutter_app/README.md` for mobile details
- Review `BUILD_SUMMARY.md` for implementation details
- Check API docs at `http://localhost:8000/docs`

---

**Ready to go!** 🚀

Start with the backend, then run the mobile app. Text simplification should work immediately!
