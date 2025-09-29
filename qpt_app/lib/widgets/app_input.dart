// lib/widgets/app_input.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType; // <-- 1. keyboardType 파라미터 추가
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const AppInput({
    super.key,
    this.controller,
    this.initialValue,
    this.hintText,
    this.obscureText = false,
    this.keyboardType, // <-- 2. 생성자에 추가
    this.validator,
    this.onSaved,
  }) : assert(initialValue == null || controller == null,
  'Cannot provide both a controller and an initialValue.');

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType, // <-- 3. TextFormField에 연결
      validator: validator,
      onSaved: onSaved,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}