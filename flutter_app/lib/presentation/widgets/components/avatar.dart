import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme_config.dart';

/// Premium Avatar Component
/// Features smooth animations, multiple variants, and elegant design
class ModernAvatar extends StatelessWidget {

  const ModernAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.isAI = false,
    this.showBorder = false,
  });
  final String? imageUrl;
  final String? initials;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool isAI;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget avatarContent;
    if (isAI) {
      avatarContent = Container(
        decoration: const BoxDecoration(
          gradient: ThemeConfig.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarContent = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildInitials(theme, isDark),
        errorWidget: (context, url, error) => _buildInitials(theme, isDark),
      );
    } else {
      avatarContent = _buildInitials(theme, isDark);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(
                  color: isDark ? ThemeConfig.darkBorder : ThemeConfig.borderColor,
                  width: 1,
                )
              : null,
          boxShadow: showBorder ? ThemeConfig.premiumShadow : null,
        ),
        child: ClipOval(
          child: avatarContent,
        ),
      ),
    );
  }

  Widget _buildInitials(ThemeData theme, bool isDark) {
    final displayInitials = initials ?? _generateInitials(name ?? '');
    final bgColor = backgroundColor ?? (isDark ? ThemeConfig.darkSurfaceVariant : ThemeConfig.surfaceVariant);
    final txtColor = textColor ?? (isDark ? ThemeConfig.darkTextSecondary : ThemeConfig.textSecondary);

    return Container(
      color: bgColor,
      child: Center(
        child: Text(
          displayInitials,
          style: ThemeConfig.getPrimaryTextStyle(
            color: txtColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _generateInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
