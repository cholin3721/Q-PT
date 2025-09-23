// lib/widgets/app_context_menu.dart

import 'package:flutter/material.dart';

// 어떤 위젯이든 감싸서 컨텍스트 메뉴를 추가해주는 위젯
class AppContextMenuTrigger extends StatelessWidget {
  // 컨텍스트 메뉴를 적용할 자식 위젯
  final Widget child;
  // 메뉴에 표시될 아이템 목록
  final List<PopupMenuEntry> menuItems;

  const AppContextMenuTrigger({
    super.key,
    required this.child,
    required this.menuItems,
  });

  // 메뉴를 표시하는 함수
  void _showContextMenu(BuildContext context, Offset position) {
    showMenu(
      context: context,
      // 메뉴가 나타날 위치를 지정
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      // 표시할 메뉴 아이템 목록
      items: menuItems,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector가 자식 위젯의 제스처를 감지
    return GestureDetector(
      // 1. 마우스 오른쪽 클릭을 감지
      onSecondaryTapUp: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      // 2. 모바일에서 길게 누르기를 감지
      onLongPressStart: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      child: child,
    );
  }
}