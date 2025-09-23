// lib/widgets/app_button.dart (최종 수정본)

import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum AppButtonVariant { defaults, destructive, outline, secondary, ghost, link }
enum AppButtonSize { defaults, sm, lg, icon }

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final AppButtonSize size;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.defaults,
    this.size = AppButtonSize.defaults,
  });

  @override
  Widget build(BuildContext context) {
    // 공통으로 사용할 스타일 요소들을 미리 정의
    final ButtonStyle baseStyle = ButtonStyle(
      padding: MaterialStateProperty.all(_getPadding()),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevation: MaterialStateProperty.all(0), // 모든 버튼의 그림자를 일단 제거
    );

    // variant에 따라 올바른 위젯을 선택하여 반환
    switch (variant) {
      case AppButtonVariant.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: baseStyle.copyWith(
            foregroundColor: MaterialStateProperty.all(AppColors.secondaryForeground),
            side: MaterialStateProperty.all(const BorderSide(color: AppColors.outlineBorder)),
          ),
          child: child,
        );
      case AppButtonVariant.ghost:
        return TextButton(
          onPressed: onPressed,
          style: baseStyle.copyWith(
            foregroundColor: MaterialStateProperty.all(AppColors.secondaryForeground),
          ),
          child: child,
        );
      case AppButtonVariant.link:
        return TextButton(
          onPressed: onPressed,
          style: baseStyle.copyWith(
            foregroundColor: MaterialStateProperty.all(AppColors.primary),
            textStyle: MaterialStateProperty.all(const TextStyle(decoration: TextDecoration.underline, fontSize: 14)),
          ),
          child: child,
        );
      case AppButtonVariant.destructive:
      case AppButtonVariant.secondary:
      case AppButtonVariant.defaults:
      default:
      // 이 케이스들은 모두 ElevatedButton 기반이므로 함께 처리
        return ElevatedButton(
          onPressed: onPressed,
          style: baseStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(_getBackgroundColor()),
            foregroundColor: MaterialStateProperty.all(_getForegroundColor()),
          ),
          child: child,
        );
    }
  }

  // Padding을 결정하는 헬퍼 함수
  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case AppButtonSize.icon:
        return const EdgeInsets.all(8);
      case AppButtonSize.defaults:
      default:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    }
  }

  // ElevatedButton 계열의 배경색을 결정하는 헬퍼 함수
  Color _getBackgroundColor() {
    switch (variant) {
      case AppButtonVariant.destructive:
        return AppColors.destructive;
      case AppButtonVariant.secondary:
        return AppColors.secondary;
      case AppButtonVariant.defaults:
      default:
        return AppColors.primary;
    }
  }

  // ElevatedButton 계열의 글자/아이콘 색을 결정하는 헬퍼 함수
  Color _getForegroundColor() {
    switch (variant) {
      case AppButtonVariant.destructive:
        return AppColors.destructiveForeground;
      case AppButtonVariant.secondary:
        return AppColors.secondaryForeground;
      case AppButtonVariant.defaults:
      default:
        return AppColors.primaryForeground;
    }
  }
}