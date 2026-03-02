import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool enabled;
  final int? maxLines;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      maxLines: maxLines,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Theme.of(context).iconTheme.color)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: Theme.of(context).iconTheme.color),
                onPressed: onSuffixIconTap,
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        labelStyle: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}

