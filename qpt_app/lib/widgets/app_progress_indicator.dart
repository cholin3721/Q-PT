// lib/widgets/app_progress_indicator.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppProgressIndicator extends StatelessWidget {
  // 진행률 (0.0 ~ 1.0)
  final double value;

  const AppProgressIndicator({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      minHeight: 8, // h-2 (4 * 2 = 8)
      borderRadius: BorderRadius.circular(100), // rounded-full
      backgroundColor: AppColors.primary.withOpacity(0.2), // bg-primary/20
      color: AppColors.primary, // bg-primary
    );
  }
}