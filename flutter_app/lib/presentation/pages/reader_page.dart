import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

/// Dyslexia-friendly text reader screen (placeholder for Phase 1B)
class ReaderPage extends StatefulWidget {
  final String originalText;
  final String simplifiedText;

  const ReaderPage({
    Key? key,
    required this.originalText,
    required this.simplifiedText,
  }) : super(key: key);

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool showOriginal = false;
  bool focusModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dyslexia-Friendly Reader'),
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
                      segments: const [
                        ButtonSegment(label: Text('Simplified'), value: false),
                        ButtonSegment(label: Text('Original'), value: true),
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
                title: const Text('Focus Mode'),
                subtitle: const Text('Reading ruler to improve focus'),
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
                          const SnackBar(content: Text('TTS coming soon')),
                        );
                      },
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Read Aloud'),
                    ),
                  ),
                  const SizedBox(width: ThemeConfig.spacingMedium),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Save coming soon')),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
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
