import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

/// Premium Message Bubble Component for Chat
/// Features smooth animations, elegant design, and multiple variants
class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime? timestamp;
  final String? avatarUrl;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
    this.avatarUrl,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConfig.spacingMedium,
          vertical: ThemeConfig.spacingSmall,
        ),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && avatarUrl != null) ...[
              _buildAvatar(context),
              const SizedBox(width: ThemeConfig.spacingSmall),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConfig.spacingMedium,
                      vertical: ThemeConfig.spacingMedium,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? ThemeConfig.primaryColor
                          : (isDark
                              ? ThemeConfig.darkSurfaceVariant
                              : ThemeConfig.surfaceVariant),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(ThemeConfig.radiusLarge),
                        topRight: const Radius.circular(ThemeConfig.radiusLarge),
                        bottomLeft: Radius.circular(
                            isUser ? ThemeConfig.radiusLarge : ThemeConfig.radiusXSmall),
                        bottomRight: Radius.circular(
                            isUser ? ThemeConfig.radiusXSmall : ThemeConfig.radiusLarge),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isUser
                            ? Colors.white
                            : theme.textTheme.bodyLarge?.color,
                        height: ThemeConfig.lineHeightLarge,
                      ),
                    ),
                  ),
                  if (timestamp != null) ...[
                    const SizedBox(height: ThemeConfig.spacingXSmall),
                    Text(
                      _formatTime(timestamp!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                        fontSize: ThemeConfig.fontSizeXSmall,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isUser && avatarUrl != null) ...[
              const SizedBox(width: ThemeConfig.spacingSmall),
              _buildAvatar(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: isUser
          ? ThemeConfig.primaryColor.withOpacity(0.2)
          : ThemeConfig.primaryAccent.withOpacity(0.2),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        size: 20,
        color: isUser ? ThemeConfig.primaryColor : ThemeConfig.primaryAccent,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// Typing Indicator for AI Messages
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.spacingMedium,
        vertical: ThemeConfig.spacingSmall,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: ThemeConfig.primaryAccent.withOpacity(0.2),
            child: Icon(
              Icons.smart_toy,
              size: 20,
              color: ThemeConfig.primaryAccent,
            ),
          ),
          const SizedBox(width: ThemeConfig.spacingSmall),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConfig.spacingMedium,
              vertical: ThemeConfig.spacingMedium,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? ThemeConfig.darkSurfaceVariant
                  : ThemeConfig.surfaceVariant,
              borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
            ),
            child: Row(
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  curve: Curves.easeInOut,
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat Input Field with Attachment and Voice Buttons
class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttachment;
  final VoidCallback? onVoice;
  final String hint;
  final bool isLoading;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    this.onAttachment,
    this.onVoice,
    this.hint = 'Type a message...',
    this.isLoading = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (widget.onAttachment != null) ...[
              IconButton(
                icon: Icon(
                  Icons.attach_file,
                  color: theme.textTheme.bodySmall?.color,
                ),
                onPressed: widget.onAttachment,
              ),
            ],
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? ThemeConfig.darkSurfaceVariant
                      : ThemeConfig.surfaceVariant,
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusFull),
                ),
                child: TextField(
                  controller: widget.controller,
                  enabled: !widget.isLoading,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: ThemeConfig.spacingMedium,
                      vertical: ThemeConfig.spacingMedium,
                    ),
                  ),
                  onSubmitted: (_) => widget.onSend(),
                ),
              ),
            ),
            const SizedBox(width: ThemeConfig.spacingSmall),
            if (widget.onVoice != null && !_hasText) ...[
              IconButton(
                icon: Icon(
                  Icons.mic,
                  color: theme.textTheme.bodySmall?.color,
                ),
                onPressed: widget.onVoice,
              ),
            ],
            const SizedBox(width: ThemeConfig.spacingXSmall),
            Container(
              decoration: BoxDecoration(
                color: _hasText
                    ? ThemeConfig.primaryColor
                    : (isDark
                        ? ThemeConfig.darkSurfaceVariant
                        : ThemeConfig.surfaceVariant),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _hasText ? Colors.white : theme.textTheme.bodySmall?.color ?? Colors.grey,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _hasText ? Colors.white : theme.textTheme.bodySmall?.color,
                        size: 20,
                      ),
                onPressed: _hasText && !widget.isLoading ? widget.onSend : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
