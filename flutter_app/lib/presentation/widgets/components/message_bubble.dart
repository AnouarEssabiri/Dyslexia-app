import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme_config.dart';
import 'avatar.dart';

/// Premium Message Bubble Component for Chat
/// Features smooth animations, elegant design, and optimized readability
class MessageBubble extends StatelessWidget {

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.timestamp,
    this.isLoading = false,
  });
  final String message;
  final bool isUser;
  final DateTime? timestamp;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.spacingMedium,
        vertical: ThemeConfig.spacingMedium,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const ModernAvatar(isAI: true, size: 32),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (isUser)
                  _buildUserBubble(context, isDark)
                else
                  _buildAIBubble(context, isDark),
                if (timestamp != null && !isLoading) ...[
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(timestamp!),
                    style: ThemeConfig.getPrimaryTextStyle(
                      fontSize: 11,
                      color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            const ModernAvatar(name: 'User', size: 32), // Placeholder for user avatar
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildUserBubble(BuildContext context, bool isDark) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeConfig.primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: ThemeConfig.getPrimaryTextStyle(
          fontSize: 15,
          color: Colors.white,
          height: 1.5,
        ),
      ),
    );

  Widget _buildAIBubble(BuildContext context, bool isDark) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? ThemeConfig.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? ThemeConfig.darkBorder : ThemeConfig.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: isDark ? ThemeConfig.darkBorder : ThemeConfig.borderColor,
          width: 1,
        ),
      ),
      child: SelectableText(
        message,
        style: ThemeConfig.getPrimaryTextStyle(
          fontSize: 15,
          color: isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.textPrimary,
          height: 1.6,
          useDyslexiaFont: true,
        ),
      ),
    );
  }

  Widget _buildDot(int index) => Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: ThemeConfig.primaryColor,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (c) => c.repeat()).scale(
          delay: (index * 200).ms,
          duration: 600.ms,
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.2, 1.2),
          curve: Curves.easeInOut,
        ).then().scale(
          duration: 600.ms,
          begin: const Offset(1.2, 1.2),
          end: const Offset(0.5, 0.5),
          curve: Curves.easeInOut,
        );

  String _formatTime(DateTime time) => '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}
