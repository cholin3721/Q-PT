// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // --- 프로필 섹션 ---
          Row(
            children: [
              const AppAvatar(
                radius: 32, // 아바타 크기 키우기
                imageUrl: 'https://github.com/shadcn.png',
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choli',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'choli@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // --- 일반 설정 카드 ---
          AppCard(
            content: AppCardContent(
              child: Column(
                children: [
                  _SettingsItem(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    // Switch는 상태가 바뀌므로 별도의 StatefulWidget으로 만듭니다.
                    trailing: const _NotificationSwitch(),
                  ),
                  const Divider(height: 1),
                  _SettingsItem(
                    icon: Icons.language,
                    title: 'Language',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('English', style: TextStyle(color: Colors.grey[600])),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // --- 기타 설정 카드 ---
          AppCard(
            content: AppCardContent(
              child: Column(
                children: [
                  _SettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // --- 로그아웃 버튼 ---
          AppButton(
            onPressed: () {},
            variant: AppButtonVariant.destructive,
            child: const Text('Log Out'),
          )
        ],
      ),
    );
  }
}

// 설정 메뉴 아이템을 위한 재사용 위젯
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ListTile은 설정 메뉴 만들기에 최적화된 위젯입니다.
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.mutedForeground),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// Switch의 상태 관리를 위한 작은 StatefulWidget
class _NotificationSwitch extends StatefulWidget {
  const _NotificationSwitch();

  @override
  State<_NotificationSwitch> createState() => __NotificationSwitchState();
}

class __NotificationSwitchState extends State<_NotificationSwitch> {
  bool _isEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isEnabled,
      onChanged: (bool value) {
        setState(() {
          _isEnabled = value;
        });
      },
      activeColor: AppColors.primary,
    );
  }
}