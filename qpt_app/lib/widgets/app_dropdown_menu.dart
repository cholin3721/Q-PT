// lib/widgets/app_dropdown_menu.dart

import 'package:flutter/material.dart';

class AppDropdownMenu extends StatelessWidget {
  // 메뉴를 열기 위해 클릭할 위젯 (보통 버튼)
  final Widget trigger;
  // 메뉴에 표시될 아이템 목록
  final List<PopupMenuEntry> menuItems;
  // 메뉴 아이템을 선택했을 때 호출될 함수
  final Function(dynamic)? onSelected;

  const AppDropdownMenu({
    super.key,
    required this.trigger,
    required this.menuItems,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // PopupMenuButton이 트리거와 메뉴를 모두 관리합니다.
    return PopupMenuButton(
      // itemBuilder는 메뉴가 필요할 때 호출되어 아이템 목록을 반환합니다.
      itemBuilder: (BuildContext context) => menuItems,
      // 아이템이 선택되었을 때 실행될 동작
      onSelected: onSelected,
      // 우리 디자인 시스템에 맞게 모서리를 둥글게 만듭니다.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      // 화면에 표시될 트리거 위젯
      child: trigger,
    );
  }
}