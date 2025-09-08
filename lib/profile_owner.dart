import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
      home: ProfileOwnerPage(),
    );
  }
}

class ProfileOwnerPage extends StatelessWidget {
  const ProfileOwnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background, 

      // APPBAR
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Valhalla",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: purple,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              CupertinoIcons.bell,
              color: purple,
              size: 28,
            ),
          )
        ],
      ),

      // BODY
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Avatar de usuario
              const CircleAvatar(
                radius: 60,
                backgroundColor: purple,
                child: Icon(
                  CupertinoIcons.person,
                  size: 60,
                  color: background,
                ),
              ),
              const SizedBox(height: 16),

              // Nombre de usuario
              const Text(
                "UserName",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: purple,
                ),
              ),
              const SizedBox(height: 100),

              // Botón cambiar contraseña
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
                  child: const Text(
                    "Cambiar contraseña",
                    style: TextStyle(fontSize: 16, color: background),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Botón cerrar sesión
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
                  child: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(fontSize: 16, color: background),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION
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
