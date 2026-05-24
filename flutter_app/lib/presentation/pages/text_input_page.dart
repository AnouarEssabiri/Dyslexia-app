import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_config.dart';
import '../../config/theme_config.dart';
import '../providers/simplification_provider.dart';

/// Text input and simplification page
class TextInputPage extends ConsumerStatefulWidget {
  const TextInputPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends ConsumerState<TextInputPage> {
  late TextEditingController textController;
  Future? debounceTimer;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void handleTextChange(String text) {
    // Cancel previous timer
    debounceTimer?.ignore();

    // Debounce the simplify request
    debounceTimer = Future.delayed(AppConfig.debounceDelay, () {
      if (text.isNotEmpty && text.length <= AppConfig.maxTextLength) {
        ref.read(simplificationProvider.notifier).simplifyText(text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final simplificationState = ref.watch(simplificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simplify Text'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input Section
              Text(
                'Paste or type text to simplify',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: ThemeConfig.spacingMedium),

              // Text input field
              TextField(
                controller: textController,
                onChanged: handleTextChange,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Paste your text here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                  ),
                  counterText:
                      '${textController.text.length} / ${AppConfig.maxTextLength}',
                ),
              ),
              const SizedBox(height: ThemeConfig.spacingSmall),

              // Info text
              Text(
                'The AI will simplify your text to make it easier to read.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: ThemeConfig.spacingLarge),

              // Results Section
              if (simplificationState.hasContent) ...[
                Text(
                  'Simplified Text',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: ThemeConfig.spacingMedium),

                // Simplified text display
                Container(
                  padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
                  decoration: BoxDecoration(
                    border: Border.all(color: ThemeConfig.borderColor),
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                    color: ThemeConfig.surfaceColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        simplificationState.simplifiedText!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: ThemeConfig.lineHeightLarge,
                              letterSpacing: ThemeConfig.letterSpacingWide,
                            ),
                      ),
                      const SizedBox(height: ThemeConfig.spacingMedium),
                      Text(
                        'Inference time: ${simplificationState.inferenceTimeMs?.toStringAsFixed(1)}ms',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ThemeConfig.spacingMedium),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Read aloud using TTS
                        },
                        child: const Text('Read Aloud'),
                      ),
                    ),
                    const SizedBox(width: ThemeConfig.spacingMedium),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Save to documents
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ] else if (simplificationState.isLoading)
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: ThemeConfig.spacingMedium),
                      Text(
                        'Simplifying your text...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              else if (simplificationState.error != null)
                Container(
                  padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
                  decoration: BoxDecoration(
                    color: ThemeConfig.errorColor.withOpacity(0.1),
                    border: Border.all(color: ThemeConfig.errorColor),
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Error',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: ThemeConfig.errorColor,
                            ),
                      ),
                      const SizedBox(height: ThemeConfig.spacingSmall),
                      Text(
                        simplificationState.error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
