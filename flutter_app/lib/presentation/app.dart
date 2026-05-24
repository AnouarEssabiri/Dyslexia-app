import 'package:flutter/material.dart';

import 'navigation/app_router.dart';

/// Main app widget with navigation logic
class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppRouter();
  }
}
