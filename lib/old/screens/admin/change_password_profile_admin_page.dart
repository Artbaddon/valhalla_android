import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Admin module: Change password within profile
const background = Color.fromRGBO(243, 243, 255, 1);
const blue = Color.fromRGBO(48, 51, 146, 1);
const purple = Color.fromRGBO(73, 76, 162, 1);
const lightPurple = Color.fromRGBO(73, 76, 162, 0.9);

class ChangePasswordProfileAdminPage extends StatelessWidget {
  const ChangePasswordProfileAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        centerTitle: true,
        title: const Text(
          'Valhalla',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: purple,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.bell, color: purple, size: 28),
          ),
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
      bottomNavigationBar: const _BottomNavStub(),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: purple,
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        onPressed: () {},
        icon: const Icon(CupertinoIcons.chevron_back, color: background),
      ),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: purple,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
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
          backgroundColor: lightPurple,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text(
          'Cambiar contraseña',
          style: TextStyle(fontSize: 16, color: background),
        ),
      ),
    );
  }
}

class _BottomNavStub extends StatelessWidget {
  const _BottomNavStub();
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: background,
      selectedItemColor: blue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.house_fill),
          label: 'Home',
        ),
        BottomNavigationBarItem(icon: Icon(CupertinoIcons.car), label: 'Car'),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.calendar),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.money_dollar_circle),
          label: 'Money',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.group),
          label: 'Group',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.cube_box),
          label: 'Box',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
