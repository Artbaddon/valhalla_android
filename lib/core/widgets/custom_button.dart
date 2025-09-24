import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// A reusable custom button with consistent styling
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final Widget? icon;
  final ButtonType type;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
    this.type = ButtonType.elevated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final buttonStyle = _getButtonStyle(theme);
    final child = _buildButtonChild();

    switch (type) {
      case ButtonType.elevated:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: child,
          ),
        );
      case ButtonType.outlined:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: child,
          ),
        );
      case ButtonType.text:
        return SizedBox(
          width: width,
          height: height ?? 48,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: child,
          ),
        );
    }
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    final baseColor = backgroundColor ?? theme.primaryColor;
    final foregroundColor = textColor ?? AppColors.white;
    
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return baseColor.withOpacity(0.6);
          }
          return baseColor;
        },
      ),
      foregroundColor: WidgetStateProperty.all<Color>(foregroundColor),
      side: borderColor != null
          ? WidgetStateProperty.all<BorderSide>(
              BorderSide(color: borderColor!),
            )
          : null,
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        AppTextStyles.buttonText.copyWith(color: foregroundColor),
      ),
    );
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? AppColors.white,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

enum ButtonType {
  elevated,
  outlined,
  text,
}