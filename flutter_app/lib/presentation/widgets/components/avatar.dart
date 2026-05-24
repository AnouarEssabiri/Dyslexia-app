import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';

/// Premium Avatar Component
/// Features smooth animations, multiple variants, and elegant design
class ModernAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final bool showShadow;

  const ModernAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.name,
    this.size = 48,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.showBorder = false,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor ?? _getBackgroundColor(theme),
          border: showBorder
              ? Border.all(
                  color: ThemeConfig.primaryColor,
                  width: 2,
                )
              : null,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitials(theme);
                  },
                )
              : _buildInitials(theme),
        ),
      ),
    );
  }

  Widget _buildInitials(ThemeData theme) {
    final displayInitials = initials ?? _generateInitials(name ?? '');
    final displayTextColor = textColor ?? Colors.white;

    return Center(
      child: Text(
        displayInitials,
        style: TextStyle(
          color: displayTextColor,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          letterSpacing: ThemeConfig.letterSpacingNormal,
        ),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (name != null) {
      final hash = name!.hashCode;
      final colors = [
        ThemeConfig.primaryColor,
        ThemeConfig.primaryAccent,
        ThemeConfig.infoColor,
        ThemeConfig.successColor,
        ThemeConfig.warningColor,
      ];
      return colors[hash.abs() % colors.length];
    }
    return theme.textTheme.bodySmall?.color?.withOpacity(0.2) ??
        Colors.grey.withOpacity(0.2);
  }

  String _generateInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

/// Premium Avatar Group for displaying multiple avatars
class AvatarGroup extends StatelessWidget {
  final List<String> imageUrls;
  final double size;
  final double overlap;
  final int maxVisible;

  const AvatarGroup({
    super.key,
    required this.imageUrls,
    this.size = 40,
    this.overlap = 0.5,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    final visibleImages = imageUrls.take(maxVisible).toList();
    final remainingCount = imageUrls.length - maxVisible;

    return SizedBox(
      width: size * (visibleImages.length + (remainingCount > 0 ? 1 : 0)) * (1 - overlap) + size,
      height: size,
      child: Stack(
        children: [
          for (int i = visibleImages.length - 1; i >= 0; i--)
            Positioned(
              left: i * size * (1 - overlap),
              child: ModernAvatar(
                imageUrl: visibleImages[i],
                size: size,
                showBorder: true,
              ),
            ),
          if (remainingCount > 0)
            Positioned(
              left: visibleImages.length * size * (1 - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ThemeConfig.surfaceVariant,
                  border: Border.all(
                    color: ThemeConfig.borderColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      fontSize: size * 0.35,
                      fontWeight: FontWeight.w600,
                      color: ThemeConfig.textSecondary,
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

/// Premium User Profile Avatar with status indicator
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final String? email;
  final bool isOnline;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.email,
    this.isOnline = false,
    this.size = 64,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              ModernAvatar(
                imageUrl: imageUrl,
                name: name,
                size: size,
                showBorder: true,
                showShadow: true,
              ),
              if (isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: size * 0.25,
                    height: size * 0.25,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ThemeConfig.successColor,
                      border: Border.all(
                        color: ThemeConfig.surfaceColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (name != null) ...[
            const SizedBox(height: ThemeConfig.spacingSmall),
            Text(
              name!,
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeMedium,
                fontWeight: FontWeight.w600,
                color: ThemeConfig.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (email != null) ...[
            const SizedBox(height: ThemeConfig.spacingXSmall),
            Text(
              email!,
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeSmall,
                color: ThemeConfig.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
