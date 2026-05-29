import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme_config.dart';
import '../widgets/components/modern_button.dart';
import '../widgets/components/modern_drawer.dart';

class OcrPage extends StatelessWidget {
  const OcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : ThemeConfig.backgroundColor,
      drawer: const ModernDrawer(),
      appBar: AppBar(
        title: const Text('Scan Text'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? ThemeConfig.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: ThemeConfig.premiumShadow,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 56,
                  color: ThemeConfig.primaryColor,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 40),
              Text(
                'OCR Scanning',
                style: ThemeConfig.getPrimaryTextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                'Point your camera at any text to instantly simplify and read it with AI support.',
                style: ThemeConfig.getPrimaryTextStyle(
                  fontSize: 16,
                  color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 48),
              ModernButton(
                text: 'Open Camera',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera functionality coming soon')),
                  );
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                isFullWidth: true,
              ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9)),
              const SizedBox(height: 24),
              _buildComingSoonBadge(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonBadge(bool isDark) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeConfig.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Phase 1B: Coming Soon',
        style: ThemeConfig.getPrimaryTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: ThemeConfig.primaryColor,
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
}
