import 'package:flutter/material.dart';
import 'package:valhalla_android/utils/colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final bool loading;
  final EdgeInsetsGeometry padding;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fullWidth = true,
    this.loading = false,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(label, style: const TextStyle(fontSize: 16, color: AppColors.background));

    final button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.purple.withOpacity(.9),
        padding: padding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: child,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
