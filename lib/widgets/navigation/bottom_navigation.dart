import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

/// A premium, highly polished bottom navigation bar component for Nexora.
/// Styled with precise Material 3 visual indicator states, spring animations, and high-contrast highlights.
class BottomNavigation extends StatelessWidget {
  /// Active selected tab index.
  final int selectedIndex;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16.0,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.borderTranslucent,
            width: 1.0,
          ),
        ),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: AppColors.primary.withOpacity(0.15),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
                color: AppColors.primary,
              );
            }
            return const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5,
              fontWeight: FontWeight.normal,
              color: AppColors.muted,
            );
          }),
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          height: AppDimensions.bottomNavigationHeight,
          selectedIndex: selectedIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (value) {
            if (value == selectedIndex) return;
            
            switch (value) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/live_tv');
                break;
              case 2:
                context.go('/search');
                break;
              case 3:
                context.go('/favorites');
                break;
              case 4:
                context.go('/settings');
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: const _AnimatedNavIcon(
                icon: Icons.home_outlined,
                isSelected: false,
                color: AppColors.muted,
              ),
              selectedIcon: const _AnimatedNavIcon(
                icon: Icons.home_rounded,
                isSelected: true,
                color: AppColors.primary,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const _AnimatedNavIcon(
                icon: Icons.tv_outlined,
                isSelected: false,
                color: AppColors.muted,
              ),
              selectedIcon: const _AnimatedNavIcon(
                icon: Icons.tv_rounded,
                isSelected: true,
                color: AppColors.primary,
              ),
              label: 'Live TV',
            ),
            NavigationDestination(
              icon: const _AnimatedNavIcon(
                icon: Icons.search_outlined,
                isSelected: false,
                color: AppColors.muted,
              ),
              selectedIcon: const _AnimatedNavIcon(
                icon: Icons.search_rounded,
                isSelected: true,
                color: AppColors.primary,
              ),
              label: 'Search',
            ),
            NavigationDestination(
              icon: const _AnimatedNavIcon(
                icon: Icons.favorite_border_rounded,
                isSelected: false,
                color: AppColors.muted,
              ),
              selectedIcon: const _AnimatedNavIcon(
                icon: Icons.favorite_rounded,
                isSelected: true,
                color: AppColors.primary,
              ),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: const _AnimatedNavIcon(
                icon: Icons.settings_outlined,
                isSelected: false,
                color: AppColors.muted,
              ),
              selectedIcon: const _AnimatedNavIcon(
                icon: Icons.settings_rounded,
                isSelected: true,
                color: AppColors.primary,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom nav icon containing selection bounce scaling animation.
class _AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color color;

  const _AnimatedNavIcon({
    required this.icon,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack, // Elastic athletic feel bounce
      tween: Tween<double>(begin: 0.9, end: isSelected ? 1.15 : 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Icon(
            icon,
            color: color,
            size: isSelected ? 26.0 : 23.0,
          ),
        );
      },
    );
  }
}
