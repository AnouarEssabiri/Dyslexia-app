import 'package:flutter/material.dart';

import '../../config/theme_config.dart';

/// User documents list screen (placeholder for Phase 1B)
class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.description_outlined,
                size: 64,
                color: ThemeConfig.primaryColor,
              ),
              const SizedBox(height: ThemeConfig.spacingLarge),
              Text(
                'No Documents Yet',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: ThemeConfig.spacingMedium),
              Text(
                'Start by simplifying text or scanning a document.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConfig.spacingXLarge),
              
              // Placeholder for document management
              Text(
                'Document management coming in Phase 1B.\n\n'
                'Features planned:\n'
                '• Save simplified documents\n'
                '• Organize with labels/folders\n'
                '• Search and filter\n'
                '• Sync with cloud',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
