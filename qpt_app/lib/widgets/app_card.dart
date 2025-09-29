// lib/widgets/app_card.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppCard extends StatelessWidget {
  final Widget? header;
  final Widget? content;
  final Widget? footer;
  final CrossAxisAlignment contentAlignment;
  final EdgeInsetsGeometry? margin; // 1. margin 속성 추가

  const AppCard({
    super.key,
    this.header,
    this.content,
    this.footer,
    this.contentAlignment = CrossAxisAlignment.start,
    this.margin, // 2. 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    // 3. Container를 Padding으로 감싸서 margin 효과를 줍니다.
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.outlineBorder),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: contentAlignment,
          children: [
            if (header != null) header!,
            if (content != null) content!,
            if (footer != null) footer!,
          ],
        ),
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