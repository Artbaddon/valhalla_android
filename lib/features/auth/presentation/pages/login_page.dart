import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../navigation/route_names.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.authTheme,
      child: const Scaffold(
        backgroundColor: AppColors.authBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: LoginForm(),
            ),
          ),
        ),
      ),
    );
  }
}

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
    
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    final success = await authViewModel.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    
    if (success && mounted) {
      final user = authViewModel.currentUser;
      if (user != null) {
        final target = user.role.name == 'admin' 
            ? RouteNames.adminDashboard 
            : RouteNames.ownerDashboard;
        NavigationService.pushNamedAndClearStack(target);
      }
    } else if (mounted && authViewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authViewModel.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _handleForgotPassword() {
    NavigationService.pushNamed(RouteNames.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _LoginHeading(),
              const SizedBox(height: 25),
              const _LoginSubtitle(),
              const SizedBox(height: 40),
              AuthTextField(
                controller: _emailController,
                label: 'Usuario',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              AuthTextField(
                controller: _passwordController,
                label: 'Contraseña',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: _handleForgotPassword,
                  child: const Text(
                    '¿Olvidaste tu contraseña? Recupérala aquí.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (authViewModel.isLoading)
                const LoadingWidget()
              else
                CustomButton(
                  text: 'Iniciar Sesión',
                  onPressed: _handleLogin,
                  backgroundColor: AppColors.authButton,
                  textColor: AppColors.textPrimary,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _LoginHeading extends StatelessWidget {
  const _LoginHeading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          'de vuelta',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LoginSubtitle extends StatelessWidget {
  const _LoginSubtitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Administra tu propiedad de una manera sencilla',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
