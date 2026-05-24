import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../providers/auth_provider.dart';

/// App navigation widget that handles routing based on auth state
class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Temporarily bypass authentication to show the redesigned UI
    return const HomePage();
    
    /*
    final authState = ref.watch(authProvider);

    // Show login page if not authenticated
    if (!authState.isAuthenticated) {
      return const LoginPage();
    }

    // Show home page if authenticated
    return const HomePage();
    */
  }
}
