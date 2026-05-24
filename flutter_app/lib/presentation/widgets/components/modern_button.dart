import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

/// Premium Modern Button Component
/// Features smooth animations, elegant design, and multiple variants
class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isSecondary;
  final bool isOutlined;
  final bool isText;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isSecondary = false,
    this.isOutlined = false,
    this.isText = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: (_) {
        if (!isDisabled) {
          _controller.forward();
        }
      },
      onTapUp: (_) {
        if (!isDisabled) {
          _controller.reverse();
        }
      },
      onTapCancel: () {
        _controller.reverse();
      },
      onTap: isDisabled ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.isFullWidth ? double.infinity : widget.width,
          height: widget.height ?? 48,
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: ThemeConfig.spacingLarge,
                vertical: ThemeConfig.spacingMedium,
              ),
          decoration: BoxDecoration(
            color: _getBackgroundColor(theme),
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(ThemeConfig.radiusMedium),
            border: widget.isOutlined
                ? Border.all(
                    color: _getBorderColor(theme),
                    width: 1.5,
                  )
                : null,
            boxShadow: widget.isPrimary && !isDisabled
                ? [
                    BoxShadow(
                      color: (widget.backgroundColor ?? ThemeConfig.primaryColor)
                          .withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getForegroundColor(theme),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 20,
                          color: _getForegroundColor(theme),
                        ),
                        const SizedBox(width: ThemeConfig.spacingSmall),
                      ],
                      Text(
                        widget.text,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: _getForegroundColor(theme),
                          fontWeight: FontWeight.w600,
                          letterSpacing: ThemeConfig.letterSpacingNormal,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.isText) return Colors.transparent;
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    if (widget.isOutlined) return Colors.transparent;
    if (widget.isSecondary) return theme.colorScheme.secondary;
    return widget.isPrimary ? ThemeConfig.primaryColor : theme.cardColor;
  }

  Color _getForegroundColor(ThemeData theme) {
    if (widget.foregroundColor != null) return widget.foregroundColor!;
    if (widget.isText || widget.isOutlined) {
      return widget.isPrimary ? ThemeConfig.primaryColor : theme.textTheme.bodyLarge?.color ?? Colors.black;
    }
    if (widget.isSecondary) return Colors.white;
    return Colors.white;
  }

  Color _getBorderColor(ThemeData theme) {
    if (widget.isPrimary) return ThemeConfig.primaryColor;
    return theme.dividerColor;
  }
}

/// Premium Floating Action Button
class ModernFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ModernFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? ThemeConfig.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.radiusLarge),
      ),
      child: Icon(icon, size: 24),
    );
  }
}
