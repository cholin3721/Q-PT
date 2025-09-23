// lib/widgets/app_separator.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppSeparator extends StatelessWidget {
  final Axis orientation;

  const AppSeparator({
    super.key,
    this.orientation = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    if (orientation == Axis.horizontal) {
      // 수평 구분선
      return const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.outlineBorder,
      );
    } else {
      // 수직 구분선
      return const VerticalDivider(
        width: 1,
        thickness: 1,
        color: AppColors.outlineBorder,
      );
    }
  }
}