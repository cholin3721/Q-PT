// lib/widgets/app_tabs.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppTabs extends StatefulWidget {
  final List<String> tabTitles;
  final List<Widget> tabContents;

  const AppTabs({
    super.key,
    required this.tabTitles,
    required this.tabContents,
  }) : assert(tabTitles.length == tabContents.length);

  @override
  State<AppTabs> createState() => _AppTabsState();
}

// SingleTickerProviderStateMixin은 TabController의 애니메이션을 위해 필요합니다.
class _AppTabsState extends State<AppTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // TabController를 초기화합니다.
    _tabController = TabController(length: widget.tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 탭 버튼 목록 (TabBar)
        TabBar(
          controller: _tabController,
          // 스타일링
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.mutedForeground,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          isScrollable: true, // 탭이 많을 경우 스크롤 가능
          // 탭 제목 목록으로 Tab 위젯들을 생성
          tabs: widget.tabTitles.map((title) => Tab(text: title)).toList(),
        ),
        const SizedBox(height: 16),
        // 2. 탭 내용 (TabBarView)
        // TabBarView의 높이를 내용에 맞게 조절하기 위해 SizedBox로 감쌈
        SizedBox(
          height: 150, // 예시 높이, 실제 앱에서는 내용에 따라 조절
          child: TabBarView(
            controller: _tabController,
            children: widget.tabContents,
          ),
        ),
      ],
    );
  }
}