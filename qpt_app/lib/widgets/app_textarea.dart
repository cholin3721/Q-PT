// lib/widgets/app_textarea.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppTextarea extends StatelessWidget {
  final TextEditingController? controller; // <-- 1. controller 파라미터 추가
  final String? hintText;
  final int minLines;

  const AppTextarea({
    super.key,
    this.controller, // <-- 2. 생성자에 추가
    this.hintText,
    this.minLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, // <-- 3. TextFormField에 연결
      maxLines: null,
      minLines: minLines,
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
      ),
    );
  }
}