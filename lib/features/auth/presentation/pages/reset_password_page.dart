import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/services/navigation_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_text_field.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

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
              child: ResetPasswordForm(),
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement reset password logic with use case
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se ha enviado un enlace de recuperación a tu correo'),
          backgroundColor: AppColors.success,
        ),
      );
      
      NavigationService.pop();
    }
  }

  void _handleBack() {
    NavigationService.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.authButton,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: _handleBack,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Valhalla',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Recuperar Contraseña\nIngresa tu correo para recuperar la contraseña',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 70),
          AuthTextField(
            controller: _emailController,
            label: 'Correo Electrónico',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese su correo electrónico';
              }
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(value)) {
                return 'Por favor ingrese un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),
          if (_isLoading)
            const LoadingWidget()
          else
            CustomButton(
              text: 'Recuperar Contraseña',
              onPressed: _handleResetPassword,
              backgroundColor: AppColors.authButton,
              textColor: AppColors.textPrimary,
            ),
        ],
      ),
    );
  }
}