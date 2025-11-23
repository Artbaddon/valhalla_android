import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/screens/packages/packages_page.dart';
import 'package:valhalla_android/screens/parking/parking_page.dart';
import 'package:valhalla_android/screens/payment/payments_home_page.dart';
import 'package:valhalla_android/screens/reservation/reservations_home_page.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/utils/navigation_config.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'package:valhalla_android/widgets/navigation/app_bottom_nav.dart';
import 'package:valhalla_android/widgets/navigation/top_navbar.dart';
import 'package:valhalla_android/screens/visitors/visitors_page.dart';
import 'package:valhalla_android/screens/news/news_page.dart';
import 'package:valhalla_android/screens/profile/profile_page.dart';

class HomePageShell extends StatefulWidget {
  const HomePageShell({super.key});

  @override
  State<HomePageShell> createState() => _HomePageShellState();
}

class _HomePageShellState extends State<HomePageShell> {
  int _currentIndex = 0;
  final GlobalKey _reservationsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role;
    if (role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final config = roleNavigation[role]!;
    final navItems = config.navItems;
    final safeIndex = _currentIndex.clamp(0, navItems.length - 1);
    final currentItem = navItems[safeIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavbar(role: role),
      body: _buildBody(currentItem.route),
      bottomNavigationBar: AppBottomNav(
        items: navItems,
        currentIndex: safeIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          final tappedRoute = navItems[index].route;
          if (tappedRoute == AppRoutes.reservationsHome) {
            final state = _reservationsKey.currentState as dynamic;
            try {
              state?.refresh();
            } catch (_) {
              // ignore if method not available
            }
          }
        },
      ),
    );
  }

  Widget _buildBody(String route) {
    switch (route) {
      case AppRoutes.homeAdmin:
        return const NewsPage();
      case AppRoutes.homeOwner:
        return const NewsPage();
      case AppRoutes.homeGuard:
        return const NewsPage();
      case AppRoutes.parkingHome:
        return const ParkingScreen();
      case AppRoutes.reservationsHome:
        return ReservationsHomePage(key: _reservationsKey);
      case AppRoutes.paymentsHome:
        return const PaymentsHomePage();
      case AppRoutes.visitorsHome:
        return const AdminVisitorsPage();
      case AppRoutes.packagesHome:
        return const PackagesAdminScreen();
      case AppRoutes.profilePage:
        final auth = context.watch<AuthProvider>();
        return ProfilePage(displayName: auth.user?.username ?? 'Usuario');
      default:
        return const Center(child: Text('Sección no disponible'));
    }
  }
}