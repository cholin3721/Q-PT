// lib/widgets/app_alert.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart'; // 우리가 만든 색상 파일 가져오기

enum AppAlertVariant { defaults, destructive }

class AppAlert extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final AppAlertVariant variant;

  const AppAlert({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.variant = AppAlertVariant.defaults,
  });

  @override
  Widget build(BuildContext context) {
    // variant에 따라 색상을 결정합니다.
    final Color textColor;
    final Color iconColor;
    final Color borderColor;

    switch (variant) {
      case AppAlertVariant.destructive:
        textColor = AppColors.destructive;
        iconColor = AppColors.destructive;
        borderColor = AppColors.destructive.withOpacity(0.5);
        break;
      case AppAlertVariant.defaults:
      default:
        textColor = AppColors.secondaryForeground;
        iconColor = AppColors.secondaryForeground;
        borderColor = AppColors.outlineBorder;
        break;
    }

    return Container(
      width: double.infinity, // w-full
      padding: const EdgeInsets.all(16.0), // px-4 py-3 (비슷하게)
      decoration: BoxDecoration(
        border: Border.all(color: borderColor), // border
        borderRadius: BorderRadius.circular(8.0), // rounded-lg
      ),
      child: Row(
        // 아이콘과 텍스트를 가로로 배치
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12), // gap-x-3

          // 제목과 설명을 세로로 배치하기 위해 Column 사용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 (AlertTitle)
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600, // font-medium
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4), // gap-y-0.5

                // 설명 (AlertDescription)
                Text(
                  description,
                  style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}