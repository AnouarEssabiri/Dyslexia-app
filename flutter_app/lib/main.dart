import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'config/theme_config.dart';
import 'presentation/app.dart';

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
  const DyslexiaSupportApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Dyslexia Support',
      theme: themeData,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: themeData.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      home: const App(),
    );
  }
}
