import 'package:flutter/material.dart';
import 'package:valhalla_android/config/app_colors.dart';

class RegisterPackagePage extends StatelessWidget {
  const RegisterPackagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Paquete"),
        backgroundColor: AppColors.purple,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Destinatario"),
            const SizedBox(height: 8),
            _buildTextField(),
            const SizedBox(height: 16),

            _buildLabel("Empresa de mensajería"),
            const SizedBox(height: 8),
            _buildTextField(),
            const SizedBox(height: 16),

            _buildLabel("Número de referencia"),
            const SizedBox(height: 8),
            _buildTextField(),
            const SizedBox(height: 16),

            _buildLabel("Foto"),
            const SizedBox(height: 8),
            _buildFilePicker(),
            const SizedBox(height: 24),

            // Botón registrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: lógica para registrar paquete
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Registrar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      style: const TextStyle(
        color: Colors.black, // 👈 texto que escribes será negro
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.lila,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildFilePicker() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.lightPurple, // 👈 aquí el color del borde
          width: 2, // 👈 grosor del borde
        ),
      ),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () {
              // TODO: lógica de file picker
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Seleccionar archivo'),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ningún archivo seleccionado',
              style: TextStyle(color: Colors.black54, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
