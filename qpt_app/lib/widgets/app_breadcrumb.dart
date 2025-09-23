// lib/widgets/app_breadcrumb.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppBreadcrumb extends StatelessWidget {
  // 예: ['Home', 'Products', 'Laptops']
  final List<String> items;
  // VoidCallback<int>?에서 수정된 부분
  final void Function(int)? onItemTap;

  const AppBreadcrumb({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    // 각 경로 아이템과 구분자를 담을 위젯 리스트
    List<Widget> children = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      // 마지막 아이템(현재 페이지)은 그냥 Text 위젯으로 표시
      if (isLast) {
        children.add(
          Text(
            item,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        );
      }
      // 마지막이 아닌 아이템(링크)은 TextButton으로 만들어 클릭 가능하게 함
      else {
        children.add(
          TextButton(
            onPressed: () {
              // onItemTap 콜백이 있으면 해당 인덱스를 전달
              if (onItemTap != null) {
                onItemTap!(i);
              }
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        );
        // 구분자 아이콘 추가
        children.add(
          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.mutedForeground,
          ),
        );
      }
    }

    // Wrap 위젯이 자식 위젯들을 가로로 나열하고, 공간이 부족하면 자동으로 줄바꿈 해줌
    return Wrap(
      spacing: 8, // 아이템 사이의 가로 간격
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}