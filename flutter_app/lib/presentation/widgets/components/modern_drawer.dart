import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme_config.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/language_provider.dart';
import '../../pages/history_detail_page.dart';
import 'avatar.dart';

class DrawerItem {
  const DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
}

class ModernDrawer extends ConsumerWidget {
  const ModernDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final history = ref.watch(historyProvider);

    return Drawer(
      backgroundColor: isDark ? ThemeConfig.darkBackground : ThemeConfig.backgroundColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(ThemeConfig.radiusXXLarge),
          bottomRight: Radius.circular(ThemeConfig.radiusXXLarge),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildHeader(context, isDark),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'History', isDark),
                      Consumer(
                        builder: (context, ref, child) {
                          final history = ref.watch(historyProvider);
                          final l10n = AppLocalizations.of(context);
                          if (history.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 16),
                              child: Text(
                                l10n.translate('no_history'),
                                style: ThemeConfig.getPrimaryTextStyle(
                                  fontSize: 13,
                                  color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: history.take(3).map((item) => _buildDrawerItem(
                                  context,
                                  icon: item.type == HistoryType.chat ? Icons.chat_bubble_outline : Icons.auto_awesome,
                                  title: item.title,
                                  onTap: () {
                                    Navigator.pop(context); // Close drawer
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HistoryDetailPage(item: item),
                                      ),
                                    );
                                  },
                                  isDark: isDark,
                                )).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Tools', isDark),
                      _buildDrawerItem(
                        context,
                        icon: Icons.image_outlined,
                        title: AppLocalizations.of(context).translate('pick_image'),
                        onTap: () {},
                        isDark: isDark,
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.audio_file_outlined,
                        title: AppLocalizations.of(context).translate('import_audio'),
                        onTap: () {},
                        isDark: isDark,
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.qr_code_scanner,
                        title: AppLocalizations.of(context).translate('ocr_scan'),
                        onTap: () {},
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Accessibility', isDark),
                      Consumer(
                        builder: (context, ref, child) {
                          final settings = ref.watch(settingsProvider);
                          final languageState = ref.watch(languageProvider);
                          final l10n = AppLocalizations.of(context);
                          
                          return Column(
                            children: [
                              SwitchListTile(
                                title: Text(
                                  l10n.translate('dyslexia_font'),
                                  style: ThemeConfig.getPrimaryTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: settings.useDyslexiaFont,
                                onChanged: (value) {
                                  ref.read(settingsProvider.notifier).setDyslexiaFont(value);
                                },
                                activeThumbColor: ThemeConfig.primaryColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              ListTile(
                                title: Text(
                                  l10n.translate('language'),
                                  style: ThemeConfig.getPrimaryTextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  languageState.languageName,
                                  style: ThemeConfig.getPrimaryTextStyle(
                                    fontSize: 12,
                                    color: ThemeConfig.primaryColor,
                                  ),
                                ),
                                trailing: const Icon(Icons.language, size: 20),
                                onTap: () => _showLanguageDialog(context, ref),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Account', isDark),
                      _buildDrawerItem(
                        context,
                        icon: Icons.settings_outlined,
                        title: AppLocalizations.of(context).translate('settings'),
                        onTap: () {},
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
              _buildFooter(context, isDark),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        const ModernAvatar(isAI: true, size: 40),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DyslexiaSupport',
              style: ThemeConfig.getPrimaryTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.textPrimary,
              ),
            ),
            Text(
              l10n.translate('premium_assistant'),
              style: ThemeConfig.getPrimaryTextStyle(
                fontSize: 12,
                color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    final l10n = AppLocalizations.of(context);
    String translatedTitle = title;
    
    if (title.toUpperCase() == 'HISTORY') translatedTitle = l10n.translate('history');
    if (title.toUpperCase() == 'TOOLS') translatedTitle = l10n.translate('tools');
    if (title.toUpperCase() == 'ACCESSIBILITY') translatedTitle = l10n.translate('accessibility');
    if (title.toUpperCase() == 'ACCOUNT') translatedTitle = l10n.translate('settings');

    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        translatedTitle.toUpperCase(),
        style: ThemeConfig.getPrimaryTextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    required bool isDark,
  }) => Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? ThemeConfig.darkSurfaceVariant : ThemeConfig.surfaceVariant)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: isSelected
              ? ThemeConfig.primaryColor
              : (isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary),
        ),
        title: Text(
          title,
          style: ThemeConfig.getPrimaryTextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.textPrimary)
                : (isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        ),
      ),
    );

  Widget _buildFooter(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.translate('version')} 0.1.0',
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 12,
              color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
          title: Text(
            l10n.translate('language'),
            style: ThemeConfig.getPrimaryTextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, ref, 'English', 'en'),
              _buildLanguageOption(context, ref, 'العربية (Arabic)', 'ar'),
              _buildLanguageOption(context, ref, 'Français (French)', 'fr'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, String label, String code) {
    final languageState = ref.watch(languageProvider);
    final isSelected = languageState.locale.languageCode == code;

    return ListTile(
      title: Text(
        label,
        style: ThemeConfig.getPrimaryTextStyle(
          color: isSelected ? ThemeConfig.primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: ThemeConfig.primaryColor) : null,
      onTap: () {
        ref.read(languageProvider.notifier).setLanguage(code);
        Navigator.pop(context);
      },
    );
  }
}
