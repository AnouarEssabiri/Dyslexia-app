import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme_config.dart';
import '../providers/history_provider.dart';
import '../providers/tts_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/language_provider.dart';

class HistoryDetailPage extends ConsumerWidget {

  const HistoryDetailPage({super.key, required this.item});
  final HistoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : ThemeConfig.backgroundColor,
      appBar: AppBar(
        title: Text(item.type == HistoryType.chat ? l10n.translate('chat_session') : l10n.translate('simplification')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatTimestamp(item.timestamp),
                style: ThemeConfig.getPrimaryTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ThemeConfig.primaryColor,
                ),
              ),
            ).animate().fadeIn().slideX(begin: -0.1, end: 0),
            const SizedBox(height: 20),
            Text(
              item.title,
              style: ThemeConfig.getPrimaryTextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? ThemeConfig.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(ThemeConfig.radiusXXLarge),
                border: Border.all(
                  color: isDark ? ThemeConfig.darkBorder : ThemeConfig.borderColor,
                  width: 1,
                ),
                boxShadow: ThemeConfig.premiumShadow,
              ),
              child: SelectableText(
                item.content,
                style: ThemeConfig.getPrimaryTextStyle(
                  fontSize: 16,
                  height: 1.6,
                  useDyslexiaFont: settings.useDyslexiaFont,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
            const SizedBox(height: 40),
            _buildActionButtons(context, ref, isDark, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, bool isDark, AppLocalizations l10n) {
    final isSpeaking = ref.watch(ttsProvider);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              if (isSpeaking) {
                ref.read(ttsProvider.notifier).stop();
              } else {
                ref.read(ttsProvider.notifier).speak(item.content);
              }
            },
            icon: Icon(
              isSpeaking ? Icons.stop_rounded : Icons.volume_up_outlined,
              size: 18,
            ),
            label: Text(isSpeaking ? l10n.translate('stop') : l10n.translate('read_aloud')),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
            label: Text(l10n.translate('delete'), style: const TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  String _formatTimestamp(DateTime timestamp) => '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
}
