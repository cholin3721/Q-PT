// lib/screens/profile_screen.dart (수정본)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../widgets/app_badge.dart';
import '../theme/colors.dart';

class ProfileScreen extends StatelessWidget {
  // 1. user와 onLogout을 전달받을 변수 선언
  final Map<String, dynamic> user;
  final VoidCallback onLogout;

  // 2. 생성자에서 user와 onLogout을 필수로 받도록 수정
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final userProfile = {
      'nickname': user['nickname'] ?? 'User', // 전달받은 user 데이터 사용
      'email': user['email'] ?? 'user@example.com',
      'joinDate': "2024-01-01",
      'streak': 12, 'totalWorkouts': 45, 'totalMeals': 156
    };
    final inbodyHistory = [
      {
        'date': '2024-01-15',
        'weight': 70.5,
        'muscleMass': 32.1,
        'fatMass': 12.8
      },
      {
        'date': '2024-01-01',
        'weight': 72.0,
        'muscleMass': 31.8,
        'fatMass': 14.5
      }
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildUserInfoCard(userProfile),
          const SizedBox(height: 24),
          _buildStatsOverviewCard(userProfile),
          const SizedBox(height: 24),
          _buildCurrentGoalsCard(),
          const SizedBox(height: 24),
          _buildInBodyHistoryCard(inbodyHistory),
          const SizedBox(height: 24),
          _buildSettingsActions(),
          const SizedBox(height: 24),
          _buildAppInfoCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Manage your account and track your journey',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(Map<String, dynamic> user) {
    return AppCard(
      content: AppCardContent(
        // 1. 카드 안의 내용물에 상하좌우로 패딩을 줍니다.
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.blue, Colors.green]),
              ),
              child: const Icon(
                  Icons.person_outline, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['nickname'], style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(user['email'],
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('Member since ${DateFormat.yMMMd().format(
                      DateTime.parse(user['joinDate']))}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            AppButton(onPressed: () {},
                variant: AppButtonVariant.outline,
                size: AppButtonSize.icon,
                child: const Icon(Icons.edit_outlined, size: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverviewCard(Map<String, dynamic> user) {
    return AppCard(
      header: const AppCardHeader(title: Row(children: [
        Icon(Icons.bar_chart, color: Colors.blue),
        SizedBox(width: 8),
        Text('Your Journey')
      ])),
      content: AppCardContent(
        // 1. 카드 안의 내용물에 상하좌우로 패딩을 줍니다.
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                user['streak'].toString(), 'Day Streak', Colors.blue),
            _buildStatItem(
                user['totalWorkouts'].toString(), 'Workouts', Colors.green),
            _buildStatItem(
                user['totalMeals'].toString(), 'Meals Logged', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(
            fontSize: 24, color: color, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCurrentGoalsCard() {
    return AppCard(
      header: AppCardHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Icon(Icons.track_changes, color: Colors.green),
              SizedBox(width: 8),
              Text('Current Goals')
            ]),
            AppButton(onPressed: () {},
                variant: AppButtonVariant.outline,
                size: AppButtonSize.icon,
                child: const Icon(Icons.edit_outlined, size: 16)),
          ],
        ),
      ),
      content: AppCardContent(
        // 1. 카드 안의 내용물에 상하좌우로 패딩을 줍니다.
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          children: [
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Target Weight'), Text('68.0kg')]),
            const SizedBox(height: 8),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Target Muscle Mass'), Text('33.0kg')]),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Target Date', style: TextStyle(color: Colors.grey)),
              AppBadge(
                  text: DateFormat.yMMMd().format(DateTime.parse('2024-03-01')),
                  variant: AppBadgeVariant.secondary),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInBodyHistoryCard(List<Map<String, dynamic>> history) {
    return AppCard(
      header: AppCardHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Icon(Icons.calendar_today_outlined, color: Colors.purple),
              SizedBox(width: 8),
              Text('InBody History')
            ]),
            AppButton(onPressed: () {},
                variant: AppButtonVariant.outline,
                size: AppButtonSize.sm,
                child: const Text('Add New')),
          ],
        ),
      ),
      content: AppCardContent(
        child: Column(
          children: List.generate(history.length, (index) {
            final record = history[index];
            final isLatest = index == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppBadge(text: DateFormat.yMMMd().format(DateTime.parse(
                            record['date'])), variant: AppBadgeVariant.outline),
                        if (isLatest) const AppBadge(text: 'Latest'),
                      ]),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 4,
                    children: [
                      Text('Weight: ${record['weight']}kg'),
                      Text('Muscle: ${record['muscleMass']}kg'),
                      Text('Fat: ${record['fatMass']}kg'),
                    ],
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSettingsActions() {
    return AppCard(
      content: AppCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(onPressed: () {},
                variant: AppButtonVariant.ghost,
                child: const Row(children: [
                  Icon(Icons.settings_outlined),
                  SizedBox(width: 8),
                  Text('Settings & Preferences')
                ])),
            AppButton(
                onPressed: onLogout, // onLogout 콜백 연결
                variant: AppButtonVariant.ghost,
                child: const Row(children: [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sign Out', style: TextStyle(color: Colors.red))
                ])
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    // AppCard에 새로 만든 contentAlignment 속성을 전달합니다.
    return AppCard(
      contentAlignment: CrossAxisAlignment.center, // <-- 가운데 정렬 지시!
      content: AppCardContent(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          // 이 Column은 이제 부모가 가운데 정렬을 처리하므로 crossAxisAlignment가 필요 없습니다.
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.green]),
              ),
              child: const Icon(Icons.android, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            const Text('Q-PT', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text(
                'AI. DATA. PERFORMANCE.', style: TextStyle(color: Colors.grey)),
            const Text('Version 1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}