import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme_config.dart';
import '../providers/history_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/components/modern_card.dart';
import '../widgets/components/modern_button.dart';
import '../widgets/components/avatar.dart';
import '../widgets/components/modern_drawer.dart';
import 'chat_page.dart';
import 'text_input_page.dart';
import 'history_detail_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme and language to ensure rebuilds
    ref.watch(themeModeProvider);
    final languageState = ref.watch(languageProvider);
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : ThemeConfig.backgroundColor,
      drawer: const ModernDrawer(),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark, ref, languageState),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAIPrompt(context, isDark, l10n),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, l10n.translate('ai_tools'), isDark),
                  const SizedBox(height: 16),
                  _buildToolsGrid(context, isDark, l10n),
                  const SizedBox(height: 32),
                  _buildSectionTitle(context, l10n.translate('recent_history'), isDark),
                  const SizedBox(height: 16),
                  _buildRecentHistory(context, isDark, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, WidgetRef ref, LanguageState languageState) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, size: 22),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        // Language Selector Button
        TextButton(
          onPressed: () => _showLanguageDialog(context, ref),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            languageState.locale.languageCode.toUpperCase(),
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Theme Toggle Button
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            size: 20,
          ),
          onPressed: () {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
        ),
        const SizedBox(width: 8),
        ModernAvatar(name: 'User', size: 32, showBorder: true),
        const SizedBox(width: 16),
      ],
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, ref, 'English', const Locale('en')),
            _buildLanguageOption(context, ref, 'العربية', const Locale('ar')),
            _buildLanguageOption(context, ref, 'Français', const Locale('fr')),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, String name, Locale locale) {
    final isSelected = ref.read(languageProvider).locale == locale;
    return ListTile(
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: ThemeConfig.primaryColor) : null,
      onTap: () {
        ref.read(languageProvider.notifier).setLanguage(locale.languageCode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildAIPrompt(BuildContext context, bool isDark, AppLocalizations l10n) {
    return ModernCard(
      padding: const EdgeInsets.all(24),
      backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
      showShadow: true,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: ThemeConfig.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.translate('help_read'),
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('start_conversation'),
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 15,
              color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ModernButton(
            text: l10n.translate('start_chat'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
            isFullWidth: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Text(
      title,
      style: ThemeConfig.getPrimaryTextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildToolsGrid(BuildContext context, bool isDark, AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildToolCard(
          context,
          icon: Icons.auto_awesome,
          title: l10n.translate('simplify_text'),
          color: ThemeConfig.primaryColor,
          isDark: isDark,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TextInputPage()),
            );
          },
        ),
        _buildToolCard(
          context,
          icon: Icons.qr_code_scanner,
          title: l10n.translate('ocr_scan'),
          color: Colors.purple,
          isDark: isDark,
          onTap: () {},
        ),
        _buildToolCard(
          context,
          icon: Icons.audio_file_outlined,
          title: l10n.translate('import_audio'),
          color: Colors.orange,
          isDark: isDark,
          onTap: () {},
        ),
        _buildToolCard(
          context,
          icon: Icons.image_outlined,
          title: l10n.translate('pick_image'),
          color: Colors.blue,
          isDark: isDark,
          onTap: () {},
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Text(
            title,
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final history = ref.watch(historyProvider);

        if (history.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('no_history'),
                    style: ThemeConfig.getPrimaryTextStyle(
                      color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 400.ms);
        }

        return Column(
          children: history.map((item) => _buildHistoryItem(
            context,
            item: item,
            time: _formatTimestamp(context, item.timestamp),
            isDark: isDark,
          )).toList(),
        );
      },
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${l10n.translate('mins_ago')}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${l10n.translate('hours_ago')}';
    } else if (difference.inDays == 1) {
      return l10n.translate('yesterday');
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required HistoryItem item,
    required String time,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryDetailPage(item: item),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? ThemeConfig.darkSurfaceVariant : ThemeConfig.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.type == HistoryType.chat ? Icons.chat_bubble_outline : Icons.auto_awesome,
                size: 16,
                color: ThemeConfig.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: ThemeConfig.getPrimaryTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    time,
                    style: ThemeConfig.getPrimaryTextStyle(
                      fontSize: 12,
                      color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
