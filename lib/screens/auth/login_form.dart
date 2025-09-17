import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:valhalla_android/providers/auth_provider.dart';
import 'package:valhalla_android/utils/routes.dart';
import 'auth_colors.dart';

/// Extracted login form handling validation, submission and loading state.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (success && mounted) {
      final user = authProvider.user!;
      final target = AppRoutes.homeForRole(user.roleName);
      context.go(target); // replace stack
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleForgotPassword() {
    context.push(AppRoutes.recoverPassword); // go_router based navigation
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _LoginHeading(),
          const SizedBox(height: 25),
          const _LoginSubtitle(),
          const SizedBox(height: 40),
          _EmailField(controller: _emailController),
          const SizedBox(height: 15),
          _PasswordField(controller: _passwordController),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _handleForgotPassword,
              child: const Text(
                '¿Olvidaste tu contraseña? Recupérala aquí.',
                style: TextStyle(
                  fontSize: 13,
                  color: authTextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Consumer<AuthProvider>(
            builder: (context, authProvider, _) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.status == AuthStatus.loading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: authButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: authProvider.status == AuthStatus.loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(authTextColor),
                        ),
                      )
                    : const Text('Continuar', style: TextStyle(fontSize: 16, color: authTextColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHeading extends StatelessWidget {
  const _LoginHeading();
  @override
  Widget build(BuildContext context) => const Text(
        'Valhalla',
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: authTextColor),
      );
}

class _LoginSubtitle extends StatelessWidget {
  const _LoginSubtitle();
  @override
  Widget build(BuildContext context) => const Text(
        '¡Bienvenido!\nIngresa tu correo y contraseña para ingresar\n a la aplicación',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15, color: authTextColor),
      );
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Ingrese Correo Electrónico',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su usuario';
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  const _PasswordField({required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Ingrese Contraseña',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su contraseña';
        }
        if (value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        return null;
      },
    );
  }
}
