import 'package:flutter/material.dart';
import 'package:valhalla_android/core/enums/navigation_item.dart';
import 'package:valhalla_android/navigation/navigation_manager.dart';
import 'package:valhalla_android/navigation/widgets/botttom_navbar.dart';
import 'package:valhalla_android/core/services/navigation_service.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;
  final String currentRoute;
  final PreferredSizeWidget? appBar;
  final bool showBottomNavbar;

  const AppScaffold({
    super.key,
    required this.body,
    required this.currentRoute,
    this.appBar,
    this.showBottomNavbar = true,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  void _onNavigationItemSelected(NavigationItem item) {
    final navigationManager = NavigationManager.instance;
    final route = navigationManager.getRouteForNavigationItem(item);

    if (route != widget.currentRoute) {
      NavigationService.pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: widget.body,
      bottomNavigationBar: widget.showBottomNavbar
          ? CustomBottomNavBar(
              currentRoute: widget.currentRoute,
              onItemSelected: _onNavigationItemSelected,
            )
          : null,
    );
  }
}
