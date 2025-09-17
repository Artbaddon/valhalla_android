import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/widgets/navigation/app_bottom_nav.dart';
import 'package:valhalla_android/screens/payment/payments_home_page.dart';
import 'package:valhalla_android/screens/reservation/reservations_home_page.dart';
import 'package:valhalla_android/widgets/navigation/top_navbar.dart';
import 'package:valhalla_android/screens/owner/owner_profile_section.dart';
import 'package:valhalla_android/widgets/common/coming_soon_section.dart';

// Owner dashboard with embedded tabs (mirrors admin structural approach)
class HomeOwnerPage extends StatefulWidget {
  const HomeOwnerPage({super.key});

  @override
  State<HomeOwnerPage> createState() => _HomeOwnerPageState();
}

class _HomeOwnerPageState extends State<HomeOwnerPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_index == 2) {
      body = const ReservationsHomePage();
    } else if (_index == 3) {
      body = const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: PaymentsHomePage(),
      );
    } else if (_index == 6) {
      body = const OwnerProfileSection();
    } else {
      body = const ComingSoonSection();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopNavbar(),
      body: body,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        isAdmin: false,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}




