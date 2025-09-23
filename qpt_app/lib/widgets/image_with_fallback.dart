// lib/widgets/image_with_fallback.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ImageWithFallback extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ImageWithFallback({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // 이미지 로딩 중에 보여줄 위젯
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child; // 로딩 완료
        return Container(
          width: width,
          height: height,
          color: AppColors.muted,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      // 이미지 로딩 실패 시 보여줄 위젯
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: AppColors.muted,
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.mutedForeground,
          ),
        );
      },
    );
  }
}