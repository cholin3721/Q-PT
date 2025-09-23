// lib/widgets/app_dialog.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

// Dialog의 내용물을 구성하는 메인 위젯
class AppDialogContent extends StatelessWidget {
  final Widget? header;
  final Widget? footer;
  final Widget body;

  const AppDialogContent({
    super.key,
    this.header,
    required this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 5,
      child: Stack(
        // X 닫기 버튼을 오른쪽 위에 배치하기 위해 Stack 사용
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0), // p-6
            child: Column(
              mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (header != null) header!,
                if (header != null) const SizedBox(height: 16),
                body,
                if (footer != null) const SizedBox(height: 24),
                if (footer != null) footer!,
              ],
            ),
          ),
          // X 닫기 버튼
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.mutedForeground),
              onPressed: () => Navigator.of(context).pop(), // 다이얼로그 닫기
            ),
          ),
        ],
      ),
    );
  }
}

// React의 DialogHeader 역할
class AppDialogHeader extends StatelessWidget {
  final Widget title;
  final Widget? description;

  const AppDialogHeader({
    super.key,
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle(
          // React의 DialogTitle 스타일
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          child: title,
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          DefaultTextStyle(
            // React의 DialogDescription 스타일
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
            child: description!,
          ),
        ]
      ],
    );
  }
}

// React의 DialogFooter 역할
class AppDialogFooter extends StatelessWidget {
  final List<Widget> children;
  const AppDialogFooter({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    // sm:flex-row sm:justify-end
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: children,
    );
  }
}