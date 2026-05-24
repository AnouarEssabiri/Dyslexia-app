import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme_config.dart';
import '../providers/auth_provider.dart';

/// Login page with authentication form
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isSignUp = false;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void handleAuthAction() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);

    if (isSignUp) {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name')),
        );
        return;
      }

      final success = await authNotifier.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(authProvider).error ?? 'Sign up failed')),
        );
      }
    } else {
      final success = await authNotifier.signIn(
        email: email,
        password: password,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(authProvider).error ?? 'Sign in failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isSignUp ? 'Sign Up' : 'Login'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ThemeConfig.spacingLarge),
              Text(
                isSignUp ? 'Create Account' : 'Welcome Back',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: ThemeConfig.spacingSmall),
              Text(
                isSignUp
                    ? 'Sign up to get started with simplified reading'
                    : 'Sign in to access your documents',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: ThemeConfig.spacingXLarge),

              // Name input (Sign up only)
              if (isSignUp) ...[
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                    ),
                  ),
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: ThemeConfig.spacingMedium),
              ],

              // Email input
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                  ),
                ),
                enabled: !authState.isLoading,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: ThemeConfig.spacingMedium),

              // Password input
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                  ),
                ),
                enabled: !authState.isLoading,
              ),
              const SizedBox(height: ThemeConfig.spacingXLarge),

              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : handleAuthAction,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isSignUp ? 'Sign Up' : 'Sign In'),
                ),
              ),
              const SizedBox(height: ThemeConfig.spacingMedium),

              // Toggle sign up / login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isSignUp ? 'Already have an account? ' : 'Don\'t have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: authState.isLoading
                        ? null
                        : () {
                            setState(() => isSignUp = !isSignUp);
                            emailController.clear();
                            passwordController.clear();
                            nameController.clear();
                            ref.read(authProvider.notifier).clearError();
                          },
                    child: Text(isSignUp ? 'Sign In' : 'Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
