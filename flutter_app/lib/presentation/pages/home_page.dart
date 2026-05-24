import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme_config.dart';
import '../widgets/components/modern_card.dart';
import '../widgets/components/modern_button.dart';
import '../widgets/components/avatar.dart';
import '../widgets/components/modern_drawer.dart';
import 'text_input_page.dart';

/// Premium Modern Home Page
/// Features AI assistant aesthetic, smooth animations, and elegant design
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            top: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                slivers: [
                  // Premium App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    leading: IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                      onPressed: _toggleDrawer,
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
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
                      ),
                      titlePadding: const EdgeInsets.only(
                        left: ThemeConfig.spacingLarge,
                        bottom: ThemeConfig.spacingMedium,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Good morning',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: ThemeConfig.spacingXSmall),
                          Text(
                            'Dyslexia Support',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.headlineMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          theme.brightness == Brightness.dark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        onPressed: () {
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: ThemeConfig.spacingMedium),
                        child: ModernAvatar(
                          name: 'User',
                          size: 36,
                          showBorder: true,
                        ),
                      ),
                    ],
                  ),
              
              // Main Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(ThemeConfig.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Card with Glassmorphism
                      ModernCard(
                        isGlassmorphism: true,
                        padding: const EdgeInsets.all(ThemeConfig.spacingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
                                  decoration: BoxDecoration(
                                    gradient: ThemeConfig.primaryGradient,
                                    borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: ThemeConfig.spacingMedium),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'AI-Powered Assistance',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: ThemeConfig.spacingXSmall),
                                      Text(
                                        'Simplify text, improve readability, and enhance your reading experience',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                          height: ThemeConfig.lineHeightLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: ThemeConfig.spacingXLarge),
                      
                      // Quick Actions Section
                      Text(
                        'Quick Actions',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacingMedium),
                      
                      // Action Cards Grid
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: ThemeConfig.spacingMedium,
                        mainAxisSpacing: ThemeConfig.spacingMedium,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.0,
                        children: [
                          _ActionCard(
                            icon: Icons.text_fields_rounded,
                            title: 'Simplify Text',
                            subtitle: 'AI-powered simplification',
                            color: ThemeConfig.primaryColor,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const TextInputPage(),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            icon: Icons.camera_alt_rounded,
                            title: 'Scan Document',
                            subtitle: 'OCR text extraction',
                            color: ThemeConfig.infoColor,
                            onTap: () {
                              _showComingSoon(context, 'Document Scanning');
                            },
                          ),
                          _ActionCard(
                            icon: Icons.description_rounded,
                            title: 'My Documents',
                            subtitle: 'View saved files',
                            color: ThemeConfig.successColor,
                            onTap: () {
                              _showComingSoon(context, 'Documents');
                            },
                          ),
                          _ActionCard(
                            icon: Icons.settings_rounded,
                            title: 'Settings',
                            subtitle: 'Customize app',
                            color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                            onTap: () {
                              _showComingSoon(context, 'Settings');
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: ThemeConfig.spacingXLarge),
                      
                      // Recent Activity Section
                      Text(
                        'Recent Activity',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacingMedium),
                      
                      ModernCard(
                        padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
                        child: Column(
                          children: [
                            _ActivityItem(
                              icon: Icons.text_fields,
                              title: 'Text Simplified',
                              subtitle: '2 minutes ago',
                              color: ThemeConfig.primaryColor,
                            ),
                            const Divider(),
                            _ActivityItem(
                              icon: Icons.description,
                              title: 'Document Saved',
                              subtitle: '1 hour ago',
                              color: ThemeConfig.successColor,
                            ),
                            const Divider(),
                            _ActivityItem(
                              icon: Icons.camera_alt,
                              title: 'Document Scanned',
                              subtitle: '3 hours ago',
                              color: ThemeConfig.infoColor,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: ThemeConfig.spacingXXLarge),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
      // Modern Navigation Drawer
      ModernDrawer(
          isOpen: _isDrawerOpen,
          onClose: _toggleDrawer,
          header: ModernDrawerHeader(
            userName: 'User',
            userEmail: 'user@example.com',
            onProfileTap: () {},
            onSettingsTap: () {},
          ),
          items: [
            DrawerItem(
              icon: Icons.home_rounded,
              title: 'Home',
              onTap: () {},
              isActive: true,
            ),
            DrawerItem(
              icon: Icons.chat_rounded,
              title: 'Chat',
              onTap: () {},
            ),
            DrawerItem(
              icon: Icons.description_rounded,
              title: 'Documents',
              onTap: () {},
            ),
            DrawerItem(
              icon: Icons.history_rounded,
              title: 'History',
              onTap: () {},
            ),
          ],
          secondaryItems: [
            DrawerItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              onTap: () {},
            ),
            DrawerItem(
              icon: Icons.help_rounded,
              title: 'Help & Support',
              onTap: () {},
            ),
            DrawerItem(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
        ),
        margin: const EdgeInsets.all(ThemeConfig.spacingMedium),
      ),
    );
  }
}

/// Premium Action Card with smooth animations
class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ModernCard(
          padding: const EdgeInsets.all(ThemeConfig.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ThemeConfig.radiusMedium),
                ),
                child: Icon(
                  widget.icon,
                  size: 24,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: ThemeConfig.spacingMedium),
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: ThemeConfig.spacingXSmall),
              Text(
                widget.subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Activity Item for Recent Activity Section
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacingSmall),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ThemeConfig.radiusSmall),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
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
                const SizedBox(height: ThemeConfig.spacingXSmall),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
            size: 20,
          ),
        ],
      ),
    );
  }
}
