// lib/widgets/app_popover.dart

import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import '../theme/colors.dart';

class AppPopover extends StatelessWidget {
  // Popover를 열기 위해 클릭할 위젯
  final Widget trigger;
  // Popover 안에 표시될 내용물 위젯
  final Widget content;
  // Popover의 너비
  final double? width;
  // Popover의 높이
  final double? height;

  const AppPopover({
    super.key,
    required this.trigger,
    required this.content,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // trigger 위젯을 탭했을 때 popover를 보여줌
      onTap: () {
        showPopover(
          context: context,
          // Popover의 모양과 내용
          bodyBuilder: (context) => Container(
            padding: const EdgeInsets.all(16.0),
            width: width,
            height: height,
            child: content,
          ),
          // Popover의 배경색, 모서리 둥글기 등 스타일
          backgroundColor: Colors.white,
          radius: 12,
          shadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
          // Popover가 나타나는 방향 (trigger 아래쪽)
          direction: PopoverDirection.bottom,
        );
      },
      child: trigger,
    );
  }
}