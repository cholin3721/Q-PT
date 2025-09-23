// lib/widgets/app_skeleton.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/colors.dart';

class AppSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxShape shape;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    // Shimmer.fromColors를 사용해 반짝이는 효과를 줍니다.
    return Shimmer.fromColors(
      baseColor: AppColors.muted, // 어두운 색
      highlightColor: Colors.grey.shade100, // 밝은 색
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.muted, // Shimmer 효과를 위한 배경색
          borderRadius:
              shape == BoxShape.rectangle ? BorderRadius.circular(8) : null,
          shape: shape,
        ),
      ),
    );
  }
}