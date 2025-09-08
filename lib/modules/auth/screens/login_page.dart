import 'package:flutter/material.dart';
import 'package:valhalla_android/config/app_routes_fixed.dart';

// Auth module: Login screen
const background = Color.fromRGBO(129, 134, 213, 1);
const text = Color.fromRGBO(243, 243, 255, 1);
const button = Color.fromRGBO(73, 76, 162, 1);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_emailController.text.contains('admin')) {
      Navigator.pushReplacementNamed(context, AppRoutes.homeAdmin);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.homeOwner);
    }
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.recoverPassword);
  }

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
                  '¡Bienvenido!\nIngresa tu correo y contraseña para ingresar\n a la aplicación',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: text),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Ingrese Correo Eléctronico',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Ingrese Contraseña',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _handleForgotPassword,
                    child: const Text(
                      '¿Olvidaste tu contraseña? Recuperala aquí.',
                      style: TextStyle(fontSize: 13, color: text, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: button,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Continuar', style: TextStyle(fontSize: 16, color: text)),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Demo: Use "admin@example.com" for Admin\nor any other email for Owner',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: text, fontSize: 12),
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
