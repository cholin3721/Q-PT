// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../widgets/app_badge.dart';
import 'inbody_setup_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onLogout;
  final VoidCallback onInBodyComplete;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.onInBodyComplete,
  });

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final userProfile = {
      'nickname': user['nickname'] ?? 'User',
      'email': user['email'] ?? 'user@example.com',
      'joinDate': "2024-01-01",
      'streak': 12, 'totalWorkouts': 45, 'totalMeals': 156
    };
    final inbodyHistory = [
      {'date': '2024-01-15', 'weight': 70.5, 'muscleMass': 32.1, 'fatMass': 12.8},
      {'date': '2024-01-01', 'weight': 72.0, 'muscleMass': 31.8, 'fatMass': 14.5}
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildUserInfoCard(context, userProfile),
          const SizedBox(height: 24),
          _buildStatsOverviewCard(userProfile),
          const SizedBox(height: 24),
          _buildCurrentGoalsCard(),
          const SizedBox(height: 24),
          _buildInBodyHistoryCard(context, inbodyHistory),
          const SizedBox(height: 24),
          _buildSettingsActions(),
          const SizedBox(height: 24),
          _buildAppInfoCard(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, Map<String, dynamic> user) {
    return AppCard(
      content: AppCardContent(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(radius: 32, backgroundImage: NetworkImage('https://github.com/shadcn.png')),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['nickname'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(user['email'], style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('Member since ${DateFormat.yMMMd().format(DateTime.parse(user['joinDate']))}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            AppButton(onPressed: () {}, variant: AppButtonVariant.outline, size: AppButtonSize.icon, child: const Icon(Icons.edit_outlined, size: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverviewCard(Map<String, dynamic> user) {
    return AppCard(
      header: const AppCardHeader(title: Row(children: [Icon(Icons.bar_chart, color: Colors.blue), SizedBox(width: 8), Text('Your Journey')])),
      content: AppCardContent(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(user['streak'].toString(), 'Day Streak', Colors.blue),
            _buildStatItem(user['totalWorkouts'].toString(), 'Workouts', Colors.green),
            _buildStatItem(user['totalMeals'].toString(), 'Meals Logged', Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
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
            const Row(children: [Icon(Icons.track_changes, color: Colors.green), SizedBox(width: 8), Text('Current Goals')]),
            AppButton(onPressed: () {}, variant: AppButtonVariant.outline, size: AppButtonSize.icon, child: const Icon(Icons.edit_outlined, size: 16)),
          ],
        ),
      ),
      content: AppCardContent(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          children: [
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Target Weight'), Text('68.0kg')]),
            const SizedBox(height: 8),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Target Muscle Mass'), Text('33.0kg')]),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Target Date', style: TextStyle(color: Colors.grey)),
              AppBadge(text: DateFormat.yMMMd().format(DateTime.parse('2024-03-01')), variant: AppBadgeVariant.secondary),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInBodyHistoryCard(BuildContext context, List<Map<String, dynamic>> history) {
    return AppCard(
      header: AppCardHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [Icon(Icons.calendar_today_outlined, color: Colors.purple), SizedBox(width: 8), Text('InBody History')]),
            AppButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InBodySetupScreen(user: user, onComplete: onInBodyComplete))),
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              child: const Text('Add New'),
            ),
          ],
        ),
      ),
      content: AppCardContent(
        child: Column(
          children: List.generate(history.length, (index) {
            final record = history[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBadge(text: DateFormat.yMMMd().format(DateTime.parse(record['date'])), variant: AppBadgeVariant.outline),
                  Text('Weight: ${record['weight']}kg'),
                  Text('Muscle: ${record['muscleMass']}kg'),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppButton(onPressed: () {}, variant: AppButtonVariant.ghost, child: const Row(children: [Icon(Icons.settings_outlined), SizedBox(width: 8), Text('Settings & Preferences')])),
            AppButton(onPressed: onLogout, variant: AppButtonVariant.ghost, child: const Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('Sign Out', style: TextStyle(color: Colors.red))])),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return AppCard(
      content: AppCardContent(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(colors: [Colors.blue, Colors.green]),
              ),
              child: const Icon(Icons.android, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            const Text('Q-PT', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('AI. DATA. PERFORMANCE.', style: TextStyle(color: Colors.grey)),
            const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}