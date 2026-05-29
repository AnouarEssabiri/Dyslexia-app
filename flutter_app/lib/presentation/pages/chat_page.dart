import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme_config.dart';
import '../providers/history_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/components/message_bubble.dart';
import '../widgets/components/avatar.dart';
import '../widgets/components/modern_drawer.dart';

class ChatMessage {

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
  final String text;
  final bool isUser;
  final DateTime timestamp;
}

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      final l10n = AppLocalizations.of(context);
      _messages.add(ChatMessage(
        text: l10n.translate('hello_ai'),
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    
    if (!_isRecording) {
      // Simulate finishing recording and processing
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _messageController.text = 'This is a simulated transcription of your recorded audio.';
          });
        }
      });
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final isFirstMessage = _messages.length <= 1;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    if (isFirstMessage) {
      ref.read(historyProvider.notifier).addItem(
        text.length > 30 ? '${text.substring(0, 30)}...' : text,
        'Chat session started',
        HistoryType.chat,
      );
    }

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _messages.add(ChatMessage(
            text: "I've processed your request. This is a simplified version of the text you provided, optimized for readability and clarity. Would you like me to focus on any specific part or adjust the complexity level?",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _showAttachmentMenu(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? ThemeConfig.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(ThemeConfig.radiusXXLarge)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? ThemeConfig.darkBorder : ThemeConfig.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttachmentOption(
                  context,
                  icon: Icons.mic_none_outlined,
                  label: l10n.translate('record_audio'),
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _toggleRecording();
                  },
                ),
                _buildAttachmentOption(
                  context,
                  icon: Icons.image_outlined,
                  label: l10n.translate('image'),
                  color: Colors.blue,
                  onTap: () => Navigator.pop(context),
                ),
                _buildAttachmentOption(
                  context,
                  icon: Icons.camera_alt_outlined,
                  label: l10n.translate('camera'),
                  color: Colors.purple,
                  onTap: () => Navigator.pop(context),
                ),
                _buildAttachmentOption(
                  context,
                  icon: Icons.description_outlined,
                  label: l10n.translate('document'),
                  color: Colors.orange,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : ThemeConfig.backgroundColor,
      drawer: const ModernDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          l10n.translate('assistant'),
          style: ThemeConfig.getPrimaryTextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, size: 20),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text: l10n.translate('new_chat'),
                  isUser: false,
                  timestamp: DateTime.now(),
                ));
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return MessageBubble(
                    message: _messages[index].text,
                    isUser: _messages[index].isUser,
                    timestamp: _messages[index].timestamp,
                  );
                } else {
                  return const MessageBubble(
                    message: '',
                    isUser: false,
                    isLoading: true,
                  );
                }
              },
            ),
          ),
          _buildInputArea(isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark, AppLocalizations l10n) => Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? ThemeConfig.darkBackground : ThemeConfig.backgroundColor).withOpacity(0),
            (isDark ? ThemeConfig.darkBackground : ThemeConfig.backgroundColor),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? ThemeConfig.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? ThemeConfig.darkBorder : ThemeConfig.borderColor,
            width: 1,
          ),
          boxShadow: ThemeConfig.premiumShadow,
        ),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
                  size: 22,
                ),
                onPressed: () {
                  debugPrint('Plus button tapped');
                  _showAttachmentMenu(context, isDark);
                },
              ),
            ),
            Expanded(
              child: _isRecording
                  ? Row(
                      children: [
                        const SizedBox(width: 12),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (controller) => controller.repeat())
                          .fadeIn(duration: 500.ms)
                          .fadeOut(delay: 500.ms),
                        const SizedBox(width: 8),
                        Text(
                          'Recording...',
                          style: ThemeConfig.getPrimaryTextStyle(
                            fontSize: 15,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : TextField(
                      controller: _messageController,
                      maxLines: 4,
                      minLines: 1,
                      style: ThemeConfig.getPrimaryTextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: l10n.translate('ask_anything'),
                        hintStyle: ThemeConfig.getPrimaryTextStyle(
                          fontSize: 15,
                          color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
                        ),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
            ),
            _isRecording 
                ? _buildStopRecordingButton(isDark)
                : (_messageController.text.isEmpty 
                    ? _buildMicButton(isDark) 
                    : _buildSendButton(isDark)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);

  Widget _buildMicButton(bool isDark) => Container(
      margin: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _toggleRecording,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.mic_none_outlined,
              color: Colors.red,
              size: 20,
            ),
          ),
        ),
      ),
    );

  Widget _buildStopRecordingButton(bool isDark) => Container(
      margin: const EdgeInsets.only(left: 4),
      child: Material(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _toggleRecording,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.stop,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );

  Widget _buildSendButton(bool isDark) => Container(
      margin: const EdgeInsets.only(left: 4),
      child: Material(
        color: ThemeConfig.primaryColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _sendMessage,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(
              Icons.arrow_upward,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
}
