import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/utils/navigation_config.dart';

/// Common BottomNavigationBar wrapper.
class AppBottomNav extends StatelessWidget {
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.blue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex.clamp(0, items.length - 1),
      onTap: onTap,
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(growable: false),
    );
  }
}


