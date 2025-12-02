// lib/widgets/app_progress_indicator.dart (Final Version)

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppProgressIndicator extends StatelessWidget {
  final double value;
  final Color? color; // 선택적으로 색상을 받을 수 있도록 추가

  const AppProgressIndicator({
    super.key,
    required this.value,
    this.color, // 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    // 전달받은 color를 사용하고, 없으면 기본 primary 색상을 사용
    final progressColor = color ?? AppColors.primary;

    return LinearProgressIndicator(
      value: value,
      minHeight: 8,
      borderRadius: BorderRadius.circular(100),
      backgroundColor: progressColor.withOpacity(0.2),
      color: progressColor,
    );
  }
}