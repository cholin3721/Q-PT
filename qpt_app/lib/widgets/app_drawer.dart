// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import '../screens/settings_screen.dart'; // SettingsScreen으로 이동하기 위해 필요

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // ListView의 기본 패딩을 제거해서 화면 상단에 딱 붙게 만듭니다.
        padding: EdgeInsets.zero,
        children: [
          // Drawer의 헤더 부분입니다.
          const UserAccountsDrawerHeader(
            accountName: Text(
              'Choli',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text('choli@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage('https://github.com/shadcn.png'),
            ),
            decoration: BoxDecoration(
              color: Colors.black87,
            ),
          ),
          // 메뉴 아이템들 (ListTile 위젯 사용)
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // 메뉴 아이템을 누르면 Drawer를 닫습니다.
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              // 설정 화면으로 이동하는 예시
              Navigator.pop(context); // 먼저 Drawer를 닫고
              Navigator.push( // 그 다음 SettingsScreen으로 이동
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}