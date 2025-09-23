// lib/layouts/main_layout.dart

import 'package:flutter/material.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/app_drawer.dart'; // Drawer 위젯 파일 (이전 대화에서 생성)

class MainLayout extends StatefulWidget {
  final Widget child; // 화면의 메인 콘텐츠가 될 위젯

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  bool _isSidebarExpanded = true;

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 너비를 가져옵니다.
    final screenWidth = MediaQuery.of(context).size.width;
    // 특정 너비(예: 768px)를 기준으로 모바일/데스크톱을 구분
    final isMobile = screenWidth < 768;

    if (isMobile) {
      // --- 모바일 뷰 ---
      return Scaffold(
        appBar: AppBar(
          title: const Text('Q-PT App'),
        ),
        drawer: const AppDrawer(), // 모바일에서는 Drawer를 사용
        body: widget.child,
      );
    } else {
      // --- 데스크톱 뷰 ---
      return Scaffold(
        body: Row(
          children: [
            // 1. 사이드바
            AppSidebar(isExpanded: _isSidebarExpanded),
            // 2. 메인 콘텐츠
            Expanded(
              child: Column(
                children: [
                  // 메인 콘텐츠 영역의 상단 바 (사이드바 토글 버튼 포함)
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: _toggleSidebar, // 버튼을 누르면 사이드바 상태 변경
                        ),
                        // 여기에 다른 상단 메뉴들을 추가할 수 있습니다.
                      ],
                    ),
                  ),
                  // 실제 내용이 표시될 부분
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}