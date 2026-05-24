import 'package:flutter/material.dart';
import '../../../config/theme_config.dart';
import 'modern_card.dart';
import 'avatar.dart';

/// Premium Modern Navigation Drawer
/// Features glassmorphism, smooth animations, and elegant design
class ModernDrawer extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onClose;
  final Widget? header;
  final List<DrawerItem> items;
  final List<DrawerItem>? secondaryItems;
  final Widget? footer;

  const ModernDrawer({
    super.key,
    required this.isOpen,
    required this.onClose,
    this.header,
    required this.items,
    this.secondaryItems,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isOpen ? 320 : 0,
          child: isOpen
              ? GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? ThemeConfig.darkSurface
                          : ThemeConfig.surfaceColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
                          blurRadius: 32,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (header != null) ...[
                          header!,
                          const Divider(height: 1),
                        ],
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              vertical: ThemeConfig.spacingMedium,
                            ),
                            children: [
                              ...items.map((item) => _DrawerTile(
                                    item: item,
                                    onTap: () {
                                      item.onTap();
                                      onClose();
                                    },
                                  )),
                              if (secondaryItems != null) ...[
                                const SizedBox(height: ThemeConfig.spacingLarge),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ThemeConfig.spacingLarge,
                                  ),
                                  child: Divider(),
                                ),
                                const SizedBox(height: ThemeConfig.spacingMedium),
                                ...secondaryItems!.map((item) => _DrawerTile(
                                      item: item,
                                      onTap: () {
                                        item.onTap();
                                        onClose();
                                      },
                                    )),
                              ],
                            ],
                          ),
                        ),
                        if (footer != null) footer!,
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isActive;
  final Widget? trailing;

  DrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isActive = false,
    this.trailing,
  });
}

class _DrawerTile extends StatelessWidget {
  final DrawerItem item;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConfig.spacingLarge,
          vertical: ThemeConfig.spacingMedium,
        ),
        decoration: BoxDecoration(
          color: item.isActive
              ? (isDark
                  ? ThemeConfig.primaryColor.withOpacity(0.15)
                  : ThemeConfig.primaryColor.withOpacity(0.1))
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(ThemeConfig.spacingSmall),
              decoration: BoxDecoration(
                color: item.isActive
                    ? ThemeConfig.primaryColor
                    : (isDark
                        ? ThemeConfig.darkSurfaceVariant
                        : ThemeConfig.surfaceVariant),
                borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: item.isActive
                    ? Colors.white
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(width: ThemeConfig.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w500,
                      color: item.isActive
                          ? ThemeConfig.primaryColor
                          : theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: ThemeConfig.spacingXSmall),
                    Text(
                      item.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (item.trailing != null) item.trailing!,
          ],
        ),
      ),
    );
  }
}

/// Premium Drawer Header with User Profile
class ModernDrawerHeader extends StatelessWidget {
  final String userName;
  final String? userEmail;
  final String? avatarUrl;
  final VoidCallback? onProfileTap;
  final VoidCallback? onSettingsTap;

  const ModernDrawerHeader({
    super.key,
    required this.userName,
    this.userEmail,
    this.avatarUrl,
    this.onProfileTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(ThemeConfig.spacingLarge),
      decoration: BoxDecoration(
        gradient: isDark
            ? ThemeConfig.darkGradient
            : LinearGradient(
                colors: [
                  ThemeConfig.surfaceColor,
                  ThemeConfig.surfaceVariant,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ModernAvatar(
                imageUrl: avatarUrl,
                name: userName,
                size: 56,
                showBorder: true,
                onTap: onProfileTap,
              ),
              SizedBox(width: ThemeConfig.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (userEmail != null) ...[
                      SizedBox(height: ThemeConfig.spacingXSmall),
                      Text(
                        userEmail!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onSettingsTap != null)
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  onPressed: onSettingsTap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Premium Drawer Section Header
class DrawerSectionHeader extends StatelessWidget {
  final String title;

  const DrawerSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ThemeConfig.spacingLarge,
        vertical: ThemeConfig.spacingSmall,
      ),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: ThemeConfig.letterSpacingWide,
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
        ),
      ),
    );
  }
}
