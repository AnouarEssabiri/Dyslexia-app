import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme_config.dart';
import '../widgets/components/modern_drawer.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : ThemeConfig.backgroundColor,
      drawer: const ModernDrawer(),
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? ThemeConfig.darkSurface : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: ThemeConfig.premiumShadow,
                ),
                child: const Icon(
                  Icons.file_copy_outlined,
                  size: 48,
                  color: ThemeConfig.primaryColor,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 32),
              Text(
                'No documents yet',
                style: ThemeConfig.getPrimaryTextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              Text(
                'Your simplified texts and scanned documents will appear here.',
                style: ThemeConfig.getPrimaryTextStyle(
                  fontSize: 15,
                  color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 48),
              _buildPlaceholderInfo(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderInfo(bool isDark) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurfaceVariant : ThemeConfig.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Coming Soon',
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemeConfig.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Full document management with cloud sync, folders, and search is coming in the next update.',
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 13,
              color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
}
