import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

/// Premium Modern Card Component
/// Features glassmorphism, smooth shadows, and elegant design
class ModernCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool isGlassmorphism;
  final bool isHoverable;

  const ModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.isGlassmorphism = false,
    this.isHoverable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: ThemeConfig.spacingMedium,
        vertical: ThemeConfig.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: isGlassmorphism
            ? (isDark
                ? ThemeConfig.darkGlassmorphismDecoration.color
                : ThemeConfig.glassmorphismDecoration.color)
            : backgroundColor ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(ThemeConfig.radiusLarge),
        border: isGlassmorphism
            ? (isDark
                ? ThemeConfig.darkGlassmorphismDecoration.border
                : ThemeConfig.glassmorphismDecoration.border)
            : null,
        boxShadow: isGlassmorphism
            ? (isDark
                ? ThemeConfig.darkGlassmorphismDecoration.boxShadow
                : ThemeConfig.glassmorphismDecoration.boxShadow)
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: (elevation?.toDouble() ?? 16.0),
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(ThemeConfig.radiusLarge),
          splashColor: ThemeConfig.primaryColor.withOpacity(0.1),
          highlightColor: ThemeConfig.primaryColor.withOpacity(0.05),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(ThemeConfig.spacingMedium),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Premium Action Card with icon and action
class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(ThemeConfig.spacingLarge),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
            decoration: BoxDecoration(
              color: (iconColor ?? ThemeConfig.primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
            ),
            child: Icon(
              icon,
              color: iconColor ?? ThemeConfig.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: ThemeConfig.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: ThemeConfig.spacingXSmall),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: theme.textTheme.bodySmall?.color,
            size: 20,
          ),
        ],
      ),
    );
  }
}
