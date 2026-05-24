import 'package:flutter/material.dart';

import 'navigation/app_router.dart';

/// Main app widget with navigation logic
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => const AppRouter();
}
