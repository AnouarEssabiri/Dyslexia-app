import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../providers/simplification_provider.dart';
import '../providers/tts_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/components/modern_button.dart';
import '../widgets/components/modern_card.dart';
import '../widgets/components/animations.dart';
import '../widgets/components/modern_drawer.dart';

/// Redesigned Premium Text Input and Simplification Page
class TextInputPage extends ConsumerStatefulWidget {
  const TextInputPage({super.key});

  @override
  ConsumerState<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends ConsumerState<TextInputPage> {
  late TextEditingController textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSimplify() {
    final text = textController.text.trim();
    final l10n = AppLocalizations.of(context);
    if (text.isNotEmpty && text.length <= AppConfig.maxTextLength) {
      _focusNode.unfocus();
      ref.read(simplificationProvider.notifier).simplifyText(text);
    } else if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('enter_text_error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final simplificationState = ref.watch(simplificationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : ThemeConfig.backgroundColor,
      drawer: const ModernDrawer(),
      appBar: AppBar(
        title: Text(l10n.translate('simplify_text')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection(isDark, simplificationState.isLoading, l10n),
            const SizedBox(height: 32),
            if (simplificationState.isLoading)
              _buildLoadingSection(isDark, l10n)
            else if (simplificationState.hasContent)
              _buildResultsSection(isDark, simplificationState, l10n)
            else if (simplificationState.error != null)
              _buildErrorSection(isDark, simplificationState.error!),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(bool isDark, bool isLoading, AppLocalizations l10n) {
    return PremiumAnimation(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('paste_text'),
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('ai_rewrite'),
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 14,
              color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: isDark ? ThemeConfig.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
              border: Border.all(
                color: isDark ? ThemeConfig.darkBorder : ThemeConfig.borderColor,
                width: 1,
              ),
              boxShadow: ThemeConfig.premiumShadow,
            ),
            child: TextField(
              controller: textController,
              focusNode: _focusNode,
              maxLines: 8,
              minLines: 5,
              style: ThemeConfig.getPrimaryTextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: l10n.translate('type_complex'),
                hintStyle: ThemeConfig.getPrimaryTextStyle(
                  fontSize: 15,
                  color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
                counterText: '${textController.text.length} / ${AppConfig.maxTextLength}',
                counterStyle: ThemeConfig.getPrimaryTextStyle(
                  fontSize: 12,
                  color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
                ),
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
          const SizedBox(height: 20),
          ModernButton(
            text: l10n.translate('simplify_now'),
            onPressed: isLoading ? null : _handleSimplify,
            isLoading: isLoading,
            isFullWidth: true,
            icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          PremiumShimmer(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: ThemeConfig.primaryColor, size: 30),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.translate('simplifying'),
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('optimizing'),
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 13,
              color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildResultsSection(bool isDark, SimplificationState state, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(settingsProvider);
        return PremiumAnimation(
          delay: 200.ms,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.translate('simplified_result'),
                    style: ThemeConfig.getPrimaryTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeConfig.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speed, size: 14, color: ThemeConfig.successColor),
                        const SizedBox(width: 4),
                        Text(
                          '${state.inferenceTimeMs?.toStringAsFixed(0)}ms',
                          style: ThemeConfig.getPrimaryTextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ThemeConfig.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ModernCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: isDark ? ThemeConfig.darkSurface : Colors.white,
                showShadow: true,
                child: SelectableText(
                  state.simplifiedText!,
                  style: ThemeConfig.getPrimaryTextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.textPrimary,
                    useDyslexiaFont: settings.useDyslexiaFont,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final isSpeaking = ref.watch(ttsProvider);
                        return ModernButton(
                          text: isSpeaking ? l10n.translate('stop') : l10n.translate('read_aloud'),
                          onPressed: () {
                            if (isSpeaking) {
                              ref.read(ttsProvider.notifier).stop();
                            } else {
                              ref.read(ttsProvider.notifier).speak(state.simplifiedText!);
                            }
                          },
                          isSecondary: true,
                          icon: Icon(
                            isSpeaking ? Icons.stop_rounded : Icons.volume_up_outlined,
                            size: 18,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ModernButton(
                      text: l10n.translate('save'),
                      onPressed: () {},
                      isSecondary: true,
                      icon: const Icon(Icons.bookmark_outline, size: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorSection(bool isDark, String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeConfig.errorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
        border: Border.all(color: ThemeConfig.errorColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: ThemeConfig.errorColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              error,
              style: ThemeConfig.getPrimaryTextStyle(
                fontSize: 14,
                color: ThemeConfig.errorColor,
              ),
            ),
          ),
        ],
      ),
    ).animate().shake();
  }
}
