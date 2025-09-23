// lib/widgets/app_card.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

// React의 Card 컴포넌트 역할
// lib/widgets/app_card.dart

class AppCard extends StatelessWidget {
  final Widget? header;
  final Widget? content;
  final Widget? footer;
  // 1. 카드 내용물의 가로 정렬을 위한 변수 추가
  final CrossAxisAlignment contentAlignment;

  const AppCard({
    super.key,
    this.header,
    this.content,
    this.footer,
    // 2. 기본값은 왼쪽 정렬(start), 필요시 외부에서 변경 가능
    this.contentAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineBorder),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        // 3. 고정되었던 start 대신, 외부에서 받은 contentAlignment 값을 사용
        crossAxisAlignment: contentAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) header!,
          if (content != null) content!,
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class AppCardHeader extends StatelessWidget {
  final Widget title;
  final Widget? description;
  final EdgeInsetsGeometry? padding; // 1. padding을 받을 수 있는 변수 추가

  const AppCardHeader({
    super.key,
    required this.title,
    this.description,
    this.padding, // 2. 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 3. 외부에서 받은 padding이 있으면 그것을 사용하고, 없으면 기본값을 사용
      padding: padding ?? const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            child: title,
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
              ),
              child: description!,
            ),
          ]
        ],
      ),
    );
  }
}

// React의 CardContent 역할
class AppCardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding; // 1. padding을 받을 수 있는 변수 추가

  const AppCardContent({
    super.key,
    required this.child,
    this.padding, // 2. 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 3. 외부에서 받은 padding이 있으면 그것을 사용하고, 없으면 기본값을 사용
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24.0),
      child: child,
    );
  }
}

// React의 CardFooter 역할
class AppCardFooter extends StatelessWidget {
  final Widget child;
  const AppCardFooter({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0), // px-6 pb-6 등
      child: child,
    );
  }
}