import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsNotifier extends Notifier<bool> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  bool build() {
    _initTts();
    return false;
  }

  Future<void> _initTts() async {
    _flutterTts.setCompletionHandler(() {
      state = false;
    });
    
    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      state = false;
    });

    _flutterTts.setStartHandler(() {
      print("TTS Started");
      state = true;
    });

    _flutterTts.setCancelHandler(() {
      state = false;
    });

    if (kIsWeb) {
      try {
        // Some browsers need a little time to load voices
        await Future.delayed(const Duration(milliseconds: 500));
        final voices = await _flutterTts.getVoices;
        print("Available voices: $voices");
        
        bool isLanguageAvailable = await _flutterTts.isLanguageAvailable("en-US");
        print("Language en-US available: $isLanguageAvailable");
      } catch (e) {
        print("Error getting voices: $e");
      }
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    try {
      if (state) {
        await stop();
        // Give the browser a moment to settle after stopping
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // On web, we might want to check available voices or set specific engine
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      
      final result = await _flutterTts.speak(text);
      if (result == 1) {
        state = true;
      } else {
        state = false;
        print("TTS failed to start");
      }
    } catch (e) {
      print("TTS Exception: $e");
      state = false;
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    state = false;
  }
}

final ttsProvider = NotifierProvider<TtsNotifier, bool>(() {
  return TtsNotifier();
});
