import 'package:flutter/material.dart';

// Auth module: standalone change password screen
const background = Color.fromRGBO(129, 134, 213, 1);
const text = Color.fromRGBO(243, 243, 255, 1);
const button = Color.fromRGBO(73, 76, 162, 1);

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Valhalla', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: text)),
                const SizedBox(height: 25),
                const Text(
                  'Cambiar Contraseña\nIngresa una nueva contraseña para poder ingresar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: text),
                ),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Contraseña nueva:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text)),
                ),
                const SizedBox(height: 6),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Repetir contraseña nueva:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: text)),
                ),
                const SizedBox(height: 6),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text('¿Olvidaste tu contraseña? Recuperala aquí.', style: TextStyle(fontSize: 13, color: text, fontWeight: FontWeight.w400)),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: button,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Continuar', style: TextStyle(fontSize: 16, color: text)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
