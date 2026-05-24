import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

/// OCR camera screen (placeholder for Phase 1B)
class OcrPage extends StatefulWidget {
  const OcrPage({Key? key}) : super(key: key);

  @override
  State<OcrPage> createState() => _OcrPageState();
}

class _OcrPageState extends State<OcrPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document'),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                size: 64,
                color: ThemeConfig.primaryColor,
              ),
              const SizedBox(height: ThemeConfig.spacingLarge),
              Text(
                'Camera OCR',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: ThemeConfig.spacingMedium),
              Text(
                'Point your camera at text to scan and simplify.\n\nImplementation coming in Phase 1B.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConfig.spacingXLarge),
              
              // Placeholder for camera button
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Camera functionality coming soon'),
                    ),
                  );
                },
                child: const Text('Open Camera'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
