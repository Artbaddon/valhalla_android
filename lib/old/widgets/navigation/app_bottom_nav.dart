import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';

/// Common BottomNavigationBar wrapper.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool isAdmin;
  final bool includeGroup; // admin has group + box, owner only box
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isAdmin = false,
    this.includeGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.house_fill),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.car),
        label: 'Car',
      ),
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.calendar),
        label: 'Calendar',
      ),
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.money_dollar_circle),
        label: 'Money',
      ),
      if (isAdmin && includeGroup)
        const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.group),
          label: 'Group',
        ),
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.cube_box),
        label: 'Box',
      ),
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.person),
        label: 'Profile',
      ),
    ];

    return BottomNavigationBar(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.blue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex.clamp(0, items.length - 1),
      onTap: onTap,
      items: items,
    );
  }
}
