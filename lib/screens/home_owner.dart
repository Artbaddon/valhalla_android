import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:valhalla_android/config/app_colors.dart';
import 'package:valhalla_android/widgets/app_bottom_nav.dart';
import 'package:valhalla_android/modules/payments/screens/payments_home_page.dart';
import 'package:valhalla_android/modules/reservations/screens/reservations_home_page.dart';
import 'package:valhalla_android/modules/package/screens/package_home_page.dart';

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
    Widget body;
    if (_index == 2) {
      body = const ReservationsHomePage();
    } else if (_index == 3) {
      body = const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: PaymentsHomePage(),
      );
    }else if (_index == 4) {
      body = const PackagesHomePage();
    }
     else if (_index == 6) {
      body = _buildProfile();
    } else {
      body = _buildPlaceholder();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        centerTitle: true,
        title: const Text('Valhalla', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.purple)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.bell, color: AppColors.purple, size: 28)),
        ],
      ),
      body: body,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        isAdmin: false,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }

  Widget _buildProfile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.purple,
              child: Icon(CupertinoIcons.person, size: 60, color: AppColors.background),
            ),
            const SizedBox(height: 16),
            const Text('OwnerUser', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.purple)),
            const SizedBox(height: 100),
            _PurpleButton(label: 'Cambiar contraseña', onTap: () {}),
            const SizedBox(height: 30),
            _PurpleButton(label: 'Cerrar Sesión', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(CupertinoIcons.square_grid_2x2, size: 48, color: AppColors.purple),
          SizedBox(height: 16),
          Text('Sección próximamente', style: TextStyle(fontSize: 18, color: AppColors.purple, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PurpleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PurpleButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple.withOpacity(.9),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, color: AppColors.background)),
      ),
    );
  }
}
