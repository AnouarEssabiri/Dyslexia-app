import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme_config.dart';
import '../providers/auth_provider.dart';
import '../widgets/components/modern_button.dart';
import '../widgets/components/modern_input.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleAuthAction() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);

    if (_isSignUp) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name')),
        );
        return;
      }

      await authNotifier.signUp(
        email: email,
        password: password,
        name: name,
      );
    } else {
      await authNotifier.signIn(
        email: email,
        password: password,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : ThemeConfig.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildLogo(isDark),
              const SizedBox(height: 40),
              Text(
                _isSignUp ? 'Create account' : 'Welcome back',
                style: ThemeConfig.getPrimaryTextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                _isSignUp 
                    ? 'Join our premium AI reading assistant today.' 
                    : 'Continue your journey with premium reading support.',
                style: ThemeConfig.getPrimaryTextStyle(
                  fontSize: 16,
                  color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 48),
              
              if (_isSignUp) ...[
                ModernInput(
                  label: 'Full Name',
                  hint: 'John Doe',
                  controller: _nameController,
                  prefix: const Icon(Icons.person_outline, size: 18),
                  enabled: !authState.isLoading,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 20),
              ],

              ModernInput(
                label: 'Email',
                hint: 'name@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefix: const Icon(Icons.mail_outline, size: 18),
                enabled: !authState.isLoading,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 20),

              ModernInput(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                isPassword: true,
                prefix: const Icon(Icons.lock_outline, size: 18),
                enabled: !authState.isLoading,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),

              ModernButton(                text: _isSignUp ? 'Create Account' : 'Sign In',
                onPressed: _handleAuthAction,
                isLoading: authState.isLoading,
                isFullWidth: true,
              ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: 24),

              Center(
                child: TextButton(
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          setState(() => _isSignUp = !_isSignUp);
                          ref.read(authProvider.notifier).clearError();
                        },
                  child: Text(
                    _isSignUp 
                        ? 'Already have an account? Sign In' 
                        : 'Don\'t have an account? Sign Up',
                    style: ThemeConfig.getPrimaryTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) => Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: ThemeConfig.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: 32,
      ),
    ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.5, 0.5));
}
