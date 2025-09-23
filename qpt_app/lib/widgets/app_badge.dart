// lib/widgets/app_badge.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart'; // 우리가 만든 색상 파일 가져오기

// React의 badgeVariants와 동일한 역할을 하는 enum
enum AppBadgeVariant { defaults, secondary, destructive, outline }

class AppBadge extends StatelessWidget {
  final String text;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.text,
    this.variant = AppBadgeVariant.defaults,
  });

  @override
  Widget build(BuildContext context) {
    // variant에 따라 색상 조합을 결정
    final Color backgroundColor;
    final Color foregroundColor;
    final Border? border;

    switch (variant) {
      case AppBadgeVariant.secondary:
        backgroundColor = AppColors.secondary;
        foregroundColor = AppColors.secondaryForeground;
        border = null;
        break;
      case AppBadgeVariant.destructive:
        backgroundColor = AppColors.destructive;
        foregroundColor = AppColors.destructiveForeground;
        border = null;
        break;
      case AppBadgeVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.secondaryForeground;
        border = Border.all(color: AppColors.outlineBorder);
        break;
      case AppBadgeVariant.defaults:
      default:
        backgroundColor = AppColors.primary;
        foregroundColor = AppColors.primaryForeground;
        border = null;
        break;
    }

    return Container(
      // CSS의 padding, border, border-radius 등을 설정
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6), // rounded-md
        border: border,
      ),
      // 내용물 (텍스트)
      child: Text(
        text,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12, // text-xs
          fontWeight: FontWeight.w500, // font-medium
        ),
      ),
    );
  }
}