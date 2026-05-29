import 'package:flutter/material.dart';

import '../../config/theme_config.dart';
import '../providers/language_provider.dart';
import '../widgets/components/modern_drawer.dart';

/// Dyslexia-friendly text reader screen (placeholder for Phase 1B)
class ReaderPage extends StatefulWidget {

  const ReaderPage({
    super.key,
    required this.originalText,
    required this.simplifiedText,
  });
  final String originalText;
  final String simplifiedText;

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool showOriginal = false;
  bool focusModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      drawer: const ModernDrawer(),
      appBar: AppBar(
        title: Text(l10n.translate('reader_title')),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show reader settings menu
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reader controls
              Row(
                children: [
                  Expanded(
                    child: SegmentedButton(
                      segments: [
                        ButtonSegment(label: Text(l10n.translate('simplified')), value: false),
                        ButtonSegment(label: Text(l10n.translate('original')), value: true),
                      ],
                      selected: {showOriginal},
                      onSelectionChanged: (selection) {
                        setState(() => showOriginal = selection.first);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ThemeConfig.spacingMedium),

              // Focus mode toggle
              SwitchListTile(
                title: Text(l10n.translate('focus_mode')),
                subtitle: Text(l10n.translate('focus_mode_desc')),
                value: focusModeEnabled,
                onChanged: (value) {
                  setState(() => focusModeEnabled = value);
                },
              ),
              const SizedBox(height: ThemeConfig.spacingMedium),

              // Text display with dyslexia-friendly formatting
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
                decoration: BoxDecoration(
                  border: Border.all(color: ThemeConfig.borderColor),
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                  color: ThemeConfig.surfaceColor,
                ),
                child: Text(
                  showOriginal ? widget.originalText : widget.simplifiedText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: ThemeConfig.fontFamilyPrimary, // OpenDyslexic
                        height: ThemeConfig.lineHeightXLarge,
                        letterSpacing: ThemeConfig.letterSpacingWide,
                        fontSize: 18, // Larger font for readability
                      ),
                ),
              ),
              const SizedBox(height: ThemeConfig.spacingLarge),

              // TTS controls (placeholder)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.translate('tts_coming_soon'))),
                        );
                      },
                      icon: const Icon(Icons.volume_up),
                      label: Text(l10n.translate('read_aloud')),
                    ),
                  ),
                  const SizedBox(width: ThemeConfig.spacingMedium),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.translate('save_coming_soon'))),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: Text(l10n.translate('save')),
                    ),
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
