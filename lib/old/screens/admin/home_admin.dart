import 'package:flutter/material.dart';
import 'package:valhalla_android/screens/admin/admin_packages.dart';
import 'package:valhalla_android/screens/admin/admin_parking.dart';
import 'package:valhalla_android/screens/payment/payments_home_page.dart';
import 'package:valhalla_android/screens/reservation/reservations_home_page.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/widgets/navigation/app_bottom_nav.dart';
import 'package:valhalla_android/widgets/navigation/top_navbar.dart';
import 'package:valhalla_android/screens/admin/admin_dashboard_page.dart';
import 'package:valhalla_android/screens/admin/admin_profile_section.dart';
import 'package:valhalla_android/screens/admin/admin_visitors.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  int _currentIndex = 0;
  final GlobalKey _reservationsKey = GlobalKey();

  // Keep the order in sync with AppBottomNav(isAdmin: true)
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminDashboardPage(),
      const ParkingAdminScreen(),
      ReservationsHomePage(key: _reservationsKey),
      const PaymentsHomePage(),
      const AdminVisitorsPage(),
      const PackagesAdminScreen(),
      const Padding(
        padding: EdgeInsets.all(24),
        child: AdminProfileSection(displayName: 'UserName'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavbar(),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        isAdmin: true,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 2) {
            // Trigger refresh on Reservations tab
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
}
