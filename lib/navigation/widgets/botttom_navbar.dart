import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/navigation_item.dart';
import '../navigation_manager.dart';

class CustomBottomNavBar extends StatelessWidget {
  final String currentRoute;
  final Function(NavigationItem) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentRoute,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final navigatorManager = NavigationManager.instance;
    final navItems = navigatorManager.getNavigationItems();

    if (navItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navItems.map((item) {
              final isSelected = _isItemSelected(item, currentRoute);
              return _NavBarItem(
                item: item,
                isSelected: isSelected,
                onTap: () => onItemSelected(item),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  bool _isItemSelected(NavigationItem item, String currentRoute) {
    final navigatorManager = NavigationManager.instance;
    final routeForItem = navigatorManager.getRouteForNavigationItem(item);
    return routeForItem == currentRoute;
  }
}

class _NavBarItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCupertinoIcon(item),
                color: isSelected
                    ? AppColors.navSelected
                    : AppColors.navUnselected,
                size: 24,
              ),
              const SizedBox(height: 2),
              // No labels as per old design
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCupertinoIcon(NavigationItem item) {
    switch (item) {
      case NavigationItem.dashboard:
        return CupertinoIcons.house_fill;
      case NavigationItem.parking:
        return CupertinoIcons.car;
      case NavigationItem.reservations:
        return CupertinoIcons.calendar;
      case NavigationItem.payments:
        return CupertinoIcons.money_dollar_circle;
      case NavigationItem.visitors:
        return CupertinoIcons.group;
      case NavigationItem.package:
        return CupertinoIcons.cube_box;
      case NavigationItem.profile:
        return CupertinoIcons.person;
      case NavigationItem.settings:
        return CupertinoIcons.bell;
      default:
        return CupertinoIcons.home;
    }
  }
}
