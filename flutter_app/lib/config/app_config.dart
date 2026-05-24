/// Application configuration constants
class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://netxgmyfhconjgopifhk.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ldHhnbXlmaGNvbmpnb3BpZmhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk0MTQwNDksImV4cCI6MjA5NDk5MDA0OX0.VOV6CWKLs08TY2mOkI0H9rB8tNQ4vslPmCPsduDRYdQ';

  // Backend API Configuration
  static const String backendUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api';

  // API Endpoints
  static const String healthEndpoint = '/health';
  static const String aiStatusEndpoint = '/ai/status';
  static const String simplifyEndpoint = '/simplify';
  static const String documentsEndpoint = '/documents';
  static const String authSignUpEndpoint = '/auth/signup';
  static const String authLoginEndpoint = '/auth/login';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration imageCompressionTimeout = Duration(seconds: 15);

  // File Size Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5 MB
  static const int maxTextLength = 2000; // characters

  // OCR Configuration
  static const bool ocrCompressionEnabled = true;
  static const double ocrCompressionQuality = 0.8;

  // TTS Configuration
  static const double ttsDefaultRate = 0.8;
  static const double ttsDefaultPitch = 1.0;
  static const double ttsDefaultVolume = 1.0;

  // UI Configuration
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const int documentsPageSize = 20;
}

/// Service for Hive local storage initialization
class HiveService {
  static Future<void> init() async {
    // Initialize Hive local storage for caching
    // This will be implemented with Hive box setup
  }
}
