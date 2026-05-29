import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageState {

  LanguageState({
    required this.locale,
    required this.languageName,
  });
  final Locale locale;
  final String languageName;

  LanguageState copyWith({
    Locale? locale,
    String? languageName,
  }) => LanguageState(
      locale: locale ?? this.locale,
      languageName: languageName ?? this.languageName,
    );
}

class LanguageNotifier extends Notifier<LanguageState> {
  @override
  LanguageState build() => LanguageState(
      locale: const Locale('en'),
      languageName: 'English',
    );

  void setLanguage(String langCode) {
    switch (langCode) {
      case 'ar':
        state = LanguageState(locale: const Locale('ar'), languageName: 'Arabic');
        break;
      case 'fr':
        state = LanguageState(locale: const Locale('fr'), languageName: 'French');
        break;
      case 'en':
      default:
        state = LanguageState(locale: const Locale('en'), languageName: 'English');
        break;
    }
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, LanguageState>(LanguageNotifier.new);

/// Localization Helper Class
class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Dyslexia Support',
      'accessibility': 'Accessibility',
      'language': 'Language',
      'dyslexia_font': 'OpenDyslexic Font',
      'simplify_text': 'Simplify Text',
      'start_chat': 'Start New Chat',
      'history': 'History',
      'tools': 'Tools',
      'settings': 'Settings',
      'read_aloud': 'Read Aloud',
      'stop': 'Stop',
      'save': 'Save',
      'pick_image': 'Pick Image',
      'import_audio': 'Import Audio',
      'ocr_scan': 'OCR Scanner',
      'help_read': 'How can I help you read today?',
      'start_conversation': 'Start a conversation to simplify text, scan documents, or get reading support.',
      'recent_history': 'Recent History',
      'no_history': 'No history yet',
      'ai_tools': 'AI Tools',
      'assistant': 'Assistant',
      'ask_anything': 'Ask me anything...',
      'image': 'Image',
      'camera': 'Camera',
      'document': 'Document',
      'record_audio': 'Record Audio',
      'paste_text': 'Paste your text',
      'ai_rewrite': 'Our AI will rewrite it to be clearer and easier to read.',
      'type_complex': 'Type or paste a complex sentence, paragraph, or article...',
      'simplify_now': 'Simplify Now',
      'simplifying': 'Simplifying text...',
      'optimizing': 'Optimizing for readability and clarity',
      'simplified_result': 'Simplified Result',
      'enter_text_error': 'Please enter some text to simplify',
      'premium_assistant': 'Premium Assistant',
      'version': 'Version',
      'account': 'Account',
      'new_chat': 'New Chat',
      'hello_ai': "Hello! I'm your premium AI assistant. I can help you simplify complex texts, explain difficult concepts, or summarize documents. How can I assist you today?",
      'mins_ago': 'mins ago',
      'hours_ago': 'hours ago',
      'yesterday': 'Yesterday',
      'delete': 'Delete',
      'chat_session': 'Chat Session',
      'simplification': 'Simplification',
      'reader_title': 'Dyslexia-Friendly Reader',
      'simplified': 'Simplified',
      'original': 'Original',
      'focus_mode': 'Focus Mode',
      'focus_mode_desc': 'Reading ruler to improve focus',
      'tts_coming_soon': 'TTS coming soon',
      'save_coming_soon': 'Save coming soon',
    },
    'ar': {
      'app_title': 'دعم عسر القراءة',
      'accessibility': 'إمكانية الوصول',
      'language': 'اللغة',
      'dyslexia_font': 'خط OpenDyslexic',
      'simplify_text': 'تبسيط النص',
      'start_chat': 'بدء دردشة جديدة',
      'history': 'السجل',
      'tools': 'الأدوات',
      'settings': 'الإعدادات',
      'read_aloud': 'القراءة بصوت عالٍ',
      'stop': 'إيقاف',
      'save': 'حفظ',
      'pick_image': 'اختيار صورة',
      'import_audio': 'استيراد صوت',
      'ocr_scan': 'ماسح OCR',
      'help_read': 'كيف يمكنني مساعدتك في القراءة اليوم؟',
      'start_conversation': 'ابدأ محادثة لتبسيط النص أو مسح المستندات أو الحصول على دعم القراءة.',
      'recent_history': 'السجل الأخير',
      'no_history': 'لا يوجد سجل بعد',
      'ai_tools': 'أدوات الذكاء الاصطناعي',
      'assistant': 'المساعد',
      'ask_anything': 'اسألني أي شيء...',
      'image': 'صورة',
      'camera': 'كاميرا',
      'document': 'مستند',
      'record_audio': 'تسجيل صوت',
      'paste_text': 'الصق نصك',
      'ai_rewrite': 'سيقوم الذكاء الاصطناعي الخاص بنا بإعادة كتابته ليكون أكثر وضوحاً وأسهل في القراءة.',
      'type_complex': 'اكتب أو الصق جملة معقدة أو فقرة أو مقالاً...',
      'simplify_now': 'بسط الآن',
      'simplifying': 'جاري تبسيط النص...',
      'optimizing': 'تحسين الوضوح وسهولة القراءة',
      'simplified_result': 'النتيجة المبسطة',
      'enter_text_error': 'يرجى إدخال نص لتبسيطه',
      'premium_assistant': 'مساعد متميز',
      'version': 'الإصدار',
      'account': 'الحساب',
      'new_chat': 'دردشة جديدة',
      'hello_ai': 'مرحباً! أنا مساعدك الذكي المتميز. يمكنني مساعدتك في تبسيط النصوص المعقدة، شرح المفاهيم الصعبة، أو تلخيص المستندات. كيف يمكنني مساعدتك اليوم؟',
      'mins_ago': 'منذ دقائق',
      'hours_ago': 'منذ ساعات',
      'yesterday': 'أمس',
      'delete': 'حذف',
      'chat_session': 'جلسة دردشة',
      'simplification': 'تبسيط',
      'reader_title': 'قارئ صديق لعسر القراءة',
      'simplified': 'مبسط',
      'original': 'الأصلي',
      'focus_mode': 'وضع التركيز',
      'focus_mode_desc': 'مسطرة القراءة لتحسين التركيز',
      'tts_coming_soon': 'تحويل النص إلى كلام قريباً',
      'save_coming_soon': 'الحفظ قريباً',
    },
    'fr': {
      'app_title': 'Support Dyslexie',
      'accessibility': 'Accessibilité',
      'language': 'Langue',
      'dyslexia_font': 'Police OpenDyslexic',
      'simplify_text': 'Simplifier le texte',
      'start_chat': 'Nouvelle discussion',
      'history': 'Historique',
      'tools': 'Outils',
      'settings': 'Paramètres',
      'read_aloud': 'Lecture à voix haute',
      'stop': 'Arrêter',
      'save': 'Enregistrer',
      'pick_image': 'Choisir une image',
      'import_audio': 'Importer de l\'audio',
      'ocr_scan': 'Scanner OCR',
      'help_read': 'Comment puis-je vous aider à lire aujourd\'hui ?',
      'start_conversation': 'Commencez une conversation pour simplifier du texte, scanner des documents ou obtenir de l\'aide à la lecture.',
      'recent_history': 'Historique récent',
      'no_history': 'Aucun historique pour le moment',
      'ai_tools': 'Outils d\'IA',
      'assistant': 'Assistant',
      'ask_anything': 'Demandez-moi n\'importe quoi...',
      'image': 'Image',
      'camera': 'Appareil photo',
      'document': 'Document',
      'record_audio': 'Enregistrer l\'audio',
      'paste_text': 'Collez votre texte',
      'ai_rewrite': 'Notre IA le réécrira pour qu\'il soit plus clair et plus facile à lire.',
      'type_complex': 'Tapez ou collez une phrase complexe, un paragraphe ou un article...',
      'simplify_now': 'Simplifier maintenant',
      'simplifying': 'Simplification du texte...',
      'optimizing': 'Optimisation de la lisibilité et de la clarté',
      'simplified_result': 'Résultat simplifié',
      'enter_text_error': 'Veuillez saisir du texte à simplifier',
      'premium_assistant': 'Assistant Premium',
      'version': 'Version',
      'account': 'Compte',
      'new_chat': 'Nouvelle discussion',
      'hello_ai': "Bonjour ! Je suis votre assistant IA premium. Je peux vous aider à simplifier des textes complexes, expliquer des concepts difficiles ou résumer des documents. Comment puis-je vous aider aujourd'hui ?",
      'mins_ago': 'il y a quelques minutes',
      'hours_ago': 'il y a quelques heures',
      'yesterday': 'Hier',
      'delete': 'Supprimer',
      'chat_session': 'Session de chat',
      'simplification': 'Simplification',
      'reader_title': 'Lecteur adapté à la dyslexie',
      'simplified': 'Simplifié',
      'original': 'Original',
      'focus_mode': 'Mode focus',
      'focus_mode_desc': 'Règle de lecture pour améliorer la concentration',
      'tts_coming_soon': 'Synthèse vocale bientôt disponible',
      'save_coming_soon': 'Enregistrement bientôt disponible',
    },
  };

  String translate(String key) => _localizedValues[locale.languageCode]?[key] ?? key;

  static AppLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return AppLocalizations(locale);
  }
}
