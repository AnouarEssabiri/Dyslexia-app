import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_config.dart';
import 'config/theme_config.dart';
import 'presentation/app.dart';
import 'presentation/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Initialize Hive
  await HiveService.init();

  runApp(
    const ProviderScope(
      child: DyslexiaSupportApp(),
    ),
  );
}

class DyslexiaSupportApp extends ConsumerWidget {
  const DyslexiaSupportApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final languageState = ref.watch(languageProvider);

    return MaterialApp(
      title: 'Dyslexia Support',
      theme: theme,
      locale: languageState.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('fr'),
      ],
      home: const App(),
      debugShowCheckedModeBanner: false,
    );
  }
}
