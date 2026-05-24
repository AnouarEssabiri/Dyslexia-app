import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

/// Premium Modern Card Component
/// Features clean borders, subtle shadows, and elegant design
class ModernCard extends StatelessWidget {

  const ModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.showShadow = false,
    this.showBorder = true,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool showShadow;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final decoration = BoxDecoration(
      color: backgroundColor ?? (isDark ? ThemeConfig.darkSurface : ThemeConfig.surfaceColor),
      borderRadius: borderRadius ?? BorderRadius.circular(ThemeConfig.radiusLarge),
      border: showBorder
          ? Border.all(
              color: isDark ? ThemeConfig.darkBorder : ThemeConfig.borderColor,
              width: 1,
            )
          : null,
      boxShadow: showShadow ? ThemeConfig.premiumShadow : null,
    );

    return Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(ThemeConfig.radiusLarge),
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

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.backgroundColor,
  });
  final Widget icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ModernCard(
      onTap: onTap,
      backgroundColor: backgroundColor,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(ThemeConfig.spacingSmall),
            decoration: BoxDecoration(
              color: isDark ? ThemeConfig.darkSurfaceVariant : ThemeConfig.surfaceVariant,
              borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
            ),
            child: icon,
          ),
          const SizedBox(width: ThemeConfig.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ThemeConfig.getPrimaryTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: ThemeConfig.getPrimaryTextStyle(
                      fontSize: 13,
                      color: isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? ThemeConfig.darkTextTertiary : ThemeConfig.textTertiary,
          ),
        ],
      ),
    );
  }
}
