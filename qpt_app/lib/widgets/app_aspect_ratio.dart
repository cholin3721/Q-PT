// lib/widgets/app_aspect_ratio.dart

import 'package:flutter/material.dart';

class AppAspectRatio extends StatelessWidget {
  final double ratio; // 예: 16/9, 1/1, 4/3
  final Widget child;

  const AppAspectRatio({
    super.key,
    required this.ratio,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Flutter의 내장 AspectRatio 위젯을 그대로 사용합니다.
    return AspectRatio(
      aspectRatio: ratio,
      child: child,
    );
  }
}