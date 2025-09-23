// lib/widgets/app_pagination.dart

import 'package:flutter/material.dart';
import 'app_button.dart';

class AppPagination extends StatefulWidget {
  final int totalPages;
  final Function(int page) onPageChanged;

  const AppPagination({
    super.key,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  State<AppPagination> createState() => _AppPaginationState();
}

class _AppPaginationState extends State<AppPagination> {
  int _currentPage = 1;

  void _goToPage(int page) {
    if (page >= 1 && page <= widget.totalPages) {
      setState(() {
        _currentPage = page;
      });
      widget.onPageChanged(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous Button
        AppButton(
          onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
          variant: AppButtonVariant.outline,
          size: AppButtonSize.sm,
          child: const Icon(Icons.chevron_left, size: 16),
        ),
        const SizedBox(width: 8),

        // Page Number Buttons (Simple version)
        // 여기서는 간단하게 현재 페이지만 표시합니다.
        // 실제 앱에서는 페이지 번호 목록과 ... (Ellipsis)를 계산하는 로직이 필요합니다.
        AppButton(
          onPressed: () {},
          variant: AppButtonVariant.outline,
          size: AppButtonSize.sm,
          child: Text('$_currentPage'),
        ),

        const SizedBox(width: 8),
        // Next Button
        AppButton(
          onPressed: _currentPage < widget.totalPages ? () => _goToPage(_currentPage + 1) : null,
          variant: AppButtonVariant.outline,
          size: AppButtonSize.sm,
          child: const Icon(Icons.chevron_right, size: 16),
        ),
      ],
    );
  }
}