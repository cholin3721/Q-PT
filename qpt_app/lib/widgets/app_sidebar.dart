// lib/widgets/app_sidebar.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppSidebar extends StatelessWidget {
  final bool isExpanded; // 사이드바가 펼쳐진 상태인지 여부

  const AppSidebar({super.key, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    // AnimatedContainer를 사용해 너비 변경 시 부드러운 애니메이션 효과를 줍니다.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 256 : 64, // 펼쳤을 때와 접었을 때의 너비
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          // 로고나 헤더가 들어갈 공간
          Container(
            height: 64,
            alignment: Alignment.center,
            child: isExpanded
                ? const Text('Q-PT', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                : const Icon(Icons.flash_on),
          ),
          const Divider(height: 1),
          // 메뉴 아이템 목록
          Expanded(
            child: ListView(
              children: [
                _SidebarMenuItem(
                  icon: Icons.dashboard_outlined,
                  text: 'Dashboard',
                  isExpanded: isExpanded,
                  onTap: () {},
                ),
                _SidebarMenuItem(
                  icon: Icons.people_outline,
                  text: 'Customers',
                  isExpanded: isExpanded,
                  onTap: () {},
                ),
                _SidebarMenuItem(
                  icon: Icons.shopping_cart_outlined,
                  text: 'Orders',
                  isExpanded: isExpanded,
                  onTap: () {},
                ),
                _SidebarMenuItem(
                  icon: Icons.analytics_outlined,
                  text: 'Analytics',
                  isExpanded: isExpanded,
                  onTap: () {},
                ),
              ],
            ),
          ),
          // 푸터 (예: 설정 버튼)
          const Divider(height: 1),
          _SidebarMenuItem(
            icon: Icons.settings_outlined,
            text: 'Settings',
            isExpanded: isExpanded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// 사이드바 메뉴 아이템을 위한 재사용 위젯
class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.icon,
    required this.text,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 접혔을 때는 Tooltip으로 텍스트를 보여줍니다.
    return Tooltip(
      message: isExpanded ? '' : text, // 펼쳐졌을 땐 툴팁이 필요 없음
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(icon, color: AppColors.mutedForeground),
              const SizedBox(width: 16),
              // isExpanded 상태에 따라 텍스트를 보여주거나 숨깁니다.
              if (isExpanded)
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}