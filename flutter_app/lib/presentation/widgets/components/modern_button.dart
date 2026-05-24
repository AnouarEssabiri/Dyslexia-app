import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme_config.dart';

/// Premium Modern Button Component
/// Features smooth animations, elegant design, and multiple variants
class ModernButton extends StatelessWidget {

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isSecondary = false,
    this.isOutlined = false,
    this.isGhost = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height,
  });
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool isPrimary;
  final bool isSecondary;
  final bool isOutlined;
  final bool isGhost;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bgColor;
    Color fgColor;
    Border? border;

    if (isGhost) {
      bgColor = Colors.transparent;
      fgColor = isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary;
    } else if (isOutlined) {
      bgColor = Colors.transparent;
      fgColor = isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.textPrimary;
      border = Border.all(
        color: isDark ? ThemeConfig.darkBorder : ThemeConfig.borderColor,
        width: 1,
      );
    } else if (isSecondary) {
      bgColor = isDark ? ThemeConfig.darkSurfaceVariant : ThemeConfig.surfaceVariant;
      fgColor = isDark ? ThemeConfig.darkTextPrimary : ThemeConfig.textPrimary;
    } else {
      bgColor = ThemeConfig.primaryColor;
      fgColor = Colors.white;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        else ...[
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: ThemeConfig.getPrimaryTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ],
      ],
    );

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: isFullWidth ? double.infinity : width,
            height: height ?? 50,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
              border: border,
              boxShadow: (isPrimary && !isGhost && !isOutlined && onPressed != null)
                  ? [
                      BoxShadow(
                        color: ThemeConfig.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(child: content),
          ).animate(target: onPressed == null ? 0 : 1).scale(
                begin: const Offset(1, 1),
                end: const Offset(1, 1),
                duration: 100.ms,
              ),
        ),
      ),
    );
  }
}
