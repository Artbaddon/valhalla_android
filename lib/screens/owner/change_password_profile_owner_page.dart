import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:valhalla_android/utils/colors.dart';
import 'package:valhalla_android/widgets/navigation/app_bottom_nav.dart';

class ChangePasswordProfileOwnerPage extends StatefulWidget {
  const ChangePasswordProfileOwnerPage({super.key});
  @override
  State<ChangePasswordProfileOwnerPage> createState() => _ChangePasswordProfileOwnerPageState();
}

class _ChangePasswordProfileOwnerPageState extends State<ChangePasswordProfileOwnerPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _BackButton(),
            SizedBox(height: 32),
            _PasswordField(label: 'Ingrese su contraseña actual:'),
            SizedBox(height: 20),
            _PasswordField(label: 'Ingrese su nueva contraseña:'),
            SizedBox(height: 20),
            _PasswordField(label: 'Repita su nueva contraseña:'),
            SizedBox(height: 36),
            _SubmitButton(),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tab,
        isAdmin: false,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.purple, borderRadius: BorderRadius.circular(30)),
      child: IconButton(onPressed: () {}, icon: const Icon(CupertinoIcons.chevron_back, color: AppColors.background)),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  const _PasswordField({required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.purple)),
        const SizedBox(height: 6),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purple.withOpacity(.9),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text('Cambiar contraseña', style: TextStyle(fontSize: 16, color: AppColors.background)),
      ),
    );
  }
}

// Bottom nav stub removed; AppBottomNav used instead.



