// lib/widgets/app_avatar.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppAvatar extends StatelessWidget {
  // 네트워크 이미지 URL (선택 사항)
  final String? imageUrl;
  // 이미지가 없을 때 보여줄 글자 (선택 사항)
  final String? fallbackText;
  // 아바타 크기 (선택 사항)
  final double radius;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.radius = 20, // React 코드의 size-10 (40px)은 반지름 20에 해당
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.muted,
      // imageUrl이 null이 아니고 비어있지도 않으면 NetworkImage를 시도
      backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
          ? NetworkImage(imageUrl!)
          : null,
      // backgroundImage가 null이거나 로딩에 실패하면 child가 대신 보임
      child: (imageUrl == null || imageUrl!.isEmpty)
          ? Text(
              fallbackText ?? '', // fallbackText가 없으면 빈 텍스트
              style: const TextStyle(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.bold,
              ),
            )
          : null, // 이미지가 있으면 child는 null이어야 함
    );
  }
}