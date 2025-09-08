import 'package:flutter/material.dart';

void main() {
  runApp(const ValhallaApp());
}

const background =  Color.fromRGBO(129, 134, 213, 1);
const text =  Color.fromRGBO(243, 243, 255, 1);
const button =  Color.fromRGBO(73, 76, 162, 1);

class ValhallaApp extends StatelessWidget {
  const ValhallaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:background, 
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título
                const Text(
                  "Valhalla",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color:text,
                  ),
                ),
                const SizedBox(height: 25),

                // Subtítulo
                const Text(
                  "¡Bienvenido!\nIngresa tu correo y contraseña para ingresar\n a la aplicación",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: text,
                  ),
                ),
                const SizedBox(height: 40),

                // Campo de correo
                TextField(
                  decoration: InputDecoration(
                    hintText: "Ingrese Correo Eléctronico",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Campo de contraseña
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Ingrese Contraseña",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Recuperar contraseña
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "¿Olvidaste tu contraseña? Recuperala aquí.",
                      style: TextStyle(
                        fontSize: 13,
                        color: text,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Botón
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: button, // Botón morado oscuro
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Continuar",
                      style: TextStyle(
                        fontSize: 16,
                        color: text,
                      ),
                    ),
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
