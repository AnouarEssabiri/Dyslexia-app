# Dyslexia Support Mobile App

A Flutter mobile application designed to support users with dyslexia through text simplification, text-to-speech, and accessibility features.

## Features

### MVP (Phase 1)
- **Text Simplification**: Uses FLAN-T5 AI model to simplify complex text while preserving meaning
- **OCR Scanning**: Capture text from documents using device camera with image compression
- **Text-to-Speech**: Read simplified text aloud with sentence-level highlighting
- **Dyslexia-Friendly Reader**:
  - OpenDyslexic font support
  - Reading ruler / focus mode
  - Adjustable line height and word spacing
  - Dark mode accessibility tuning
  - Original & simplified text comparison
- **Document Management**: Save and manage simplified documents locally and in the cloud
- **User Authentication**: Sign up and login with Supabase Auth

### Future Enhancements
- Gamification and progress tracking
- Multiple text simplification models (MUSS integration)
- Personalized reading profiles
- Offline support with cached models
- Multi-language support
- Advanced analytics

## Getting Started

### Prerequisites
- Flutter 3.13.0 or higher
- Dart 3.1.0 or higher
- Android Studio / Xcode for emulator
- Supabase account (for authentication and storage)

### Installation

1. **Clone the repository**
```bash
cd flutter_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Supabase**
Update `lib/config/app_config.dart` with your Supabase credentials:
```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

4. **Configure Backend API**
Update the backend URL in `lib/config/app_config.dart`:
```dart
static const String backendUrl = 'http://your-api-url:8000';
```

5. **Run the app**
```bash
flutter run
```

## Project Structure

```
lib/
├── config/           # Configuration files
│   ├── app_config.dart
│   └── theme_config.dart
├── data/            # Data layer (repositories, models)
│   ├── local/       # Local storage (Hive)
│   ├── remote/      # API client
│   └── models/      # Data models
├── domain/          # Domain layer (entities, use cases)
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/    # Presentation layer (UI)
│   ├── pages/
│   ├── widgets/
│   ├── providers/   # Riverpod providers
│   └── utils/
└── main.dart        # App entry point
```

## Architecture

The app follows **Clean Architecture** principles:
- **Presentation Layer**: UI components, Riverpod providers for state management
- **Domain Layer**: Business logic, entities, use cases
- **Data Layer**: API clients, local storage, data models

## State Management

Uses **Riverpod** for state management:
- Providers for API calls and local data
- Consumer widgets for reactive UI updates
- Async providers for handling side effects

## Testing

### Running tests
```bash
flutter test
```

### Building for production
```bash
# iOS
flutter build ios

# Android
flutter build apk
flutter build appbundle
```

## Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Supabase Flutter Documentation](https://supabase.com/docs/reference/flutter/introduction)

## Troubleshooting

### Common Issues

1. **Dependencies not installing**
```bash
flutter clean
flutter pub get
```

2. **Build errors**
```bash
flutter clean
flutter pub upgrade
flutter run
```

3. **Hot reload not working**
```bash
flutter run --no-fast-start
```

## Contributing

See CONTRIBUTING.md for guidelines.

## License

MIT License - see LICENSE file for details

## Support

For issues and feature requests, please open an issue on GitHub.
