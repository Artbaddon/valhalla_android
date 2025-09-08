import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ValhallaApp());
}

const background =  Color.fromRGBO(243, 243, 255, 1);
const blue =  Color.fromRGBO(48, 51, 146, 1);
const purple =  Color.fromRGBO(73, 76, 162, 1);
const lila =  Color.fromRGBO(198, 203, 239, 1);
const lightPurple =  Color.fromRGBO(73, 76, 162, 0.9);
const shadow =  Color.fromRGBO(76, 72, 28, 0.25);

class ValhallaApp extends StatelessWidget {
  const ValhallaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangePasswordProfileAdminPage(),
    );
  }
}

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
          "Valhalla",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: purple,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              CupertinoIcons.bell,
              color: purple,
              size: 28,
            ),
          ),
        ],
      ),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón atrás
            Container(
              decoration: BoxDecoration(
                color: purple,
                borderRadius: BorderRadius.circular(30),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(CupertinoIcons.chevron_back, color: background),
              ),
            ),
            const SizedBox(height: 32),

            _PasswordField(label: "Ingrese su contraseña actual:"),
            const SizedBox(height: 20),
            _PasswordField(label: "Ingrese su nueva contraseña:"),
            const SizedBox(height: 20),
            _PasswordField(label: "Repita su nueva contraseña:"),
            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text("Cambiar contraseña",
                    style: TextStyle(fontSize: 16, color: background)),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: background,
        selectedItemColor: blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.car),
            label: "Car",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: "Calendar",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar_circle),
            label: "Money",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: "Group",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.cube_box),
            label: "Box",
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: "Profile",
          ),
        ],
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
        Text(label,
            style: const TextStyle(color: purple, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: shadow,
                blurRadius: 6,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const TextField(
            obscureText: true,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
