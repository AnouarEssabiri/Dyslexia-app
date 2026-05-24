import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HistoryType { chat, simplification }

class HistoryItem {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final HistoryType type;

  HistoryItem({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.type,
  });
}

class HistoryNotifier extends Notifier<List<HistoryItem>> {
  @override
  List<HistoryItem> build() {
    return [
      // Initial mock data
      HistoryItem(
        id: '1',
        title: 'Science Article Summary',
        content: 'This is a simplified version of the science article...',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: HistoryType.simplification,
      ),
      HistoryItem(
        id: '2',
        title: 'Email from Professor',
        content: 'Hello student, about the project...',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: HistoryType.chat,
      ),
    ];
  }

  void addItem(String title, String content, HistoryType type) {
    final newItem = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      timestamp: DateTime.now(),
      type: type,
    );
    state = [newItem, ...state];
  }

  void clearHistory() {
    state = [];
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<HistoryItem>>(() {
  return HistoryNotifier();
});
