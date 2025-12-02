// lib/widgets/app_tabs.dart (Side Effect 없는 수정본)

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppTabs extends StatefulWidget {
  final List<String> tabTitles;
  final List<Widget> tabContents;
  final double? contentHeight; // 1. 높이를 받을 수 있는 변수 추가

  const AppTabs({
    super.key,
    required this.tabTitles,
    required this.tabContents,
    this.contentHeight, // 2. 생성자에 추가
  }) : assert(tabTitles.length == tabContents.length);

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
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
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.mutedForeground,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.tab,
          isScrollable: true,
          tabs: widget.tabTitles.map((title) => Tab(text: title)).toList(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          // 3. 외부에서 받은 높이가 있으면 그것을 사용하고, 없으면(null이면) 기본값 150을 사용
          height: widget.contentHeight ?? 150,
          child: TabBarView(
            controller: _tabController,
            children: widget.tabContents,
          ),
        ),
      ],
    );
  }
}