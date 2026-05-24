import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme_config.dart';
import '../widgets/components/message_bubble.dart';
import '../widgets/components/avatar.dart';

/// Premium Modern Chat Screen
/// Features AI conversation layout, beautiful message bubbles, and smooth animations
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add initial welcome message
    _messages.add(ChatMessage(
      text: 'Hello! I\'m your AI reading assistant. How can I help you simplify text today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: _getSimplifiedResponse(text),
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  String _getSimplifiedResponse(String userText) {
    // This is a placeholder - in production, this would call the backend API
    return 'I\'ve analyzed your text. Here\'s a simplified version that\'s easier to read: "${userText.toLowerCase()}". Would you like me to adjust the simplification level?';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            ModernAvatar(
              name: 'AI Assistant',
              size: 36,
              showBorder: true,
            ),
            const SizedBox(width: ThemeConfig.spacingMedium),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Online',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ThemeConfig.successColor,
                    fontSize: ThemeConfig.fontSizeXSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: theme.textTheme.bodyLarge?.color,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConfig.spacingMedium,
                vertical: ThemeConfig.spacingMedium,
              ),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return MessageBubble(
                    message: _messages[index].text,
                    isUser: _messages[index].isUser,
                    timestamp: _messages[index].timestamp,
                    avatarUrl: _messages[index].isUser ? null : null,
                  );
                } else {
                  return const TypingIndicator();
                }
              },
            ),
          ),
          
          // Chat Input
          ChatInputField(
            controller: _messageController,
            onSend: _sendMessage,
            onAttachment: () {
              // Handle attachment
            },
            onVoice: () {
              // Handle voice input
            },
            hint: 'Type your message...',
            isLoading: _isTyping,
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
