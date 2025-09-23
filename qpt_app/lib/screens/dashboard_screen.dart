// lib/screens/dashboard_screen.dart (수정본)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_card.dart';
import '../widgets/app_progress_indicator.dart';
import '../widgets/app_button.dart';
import '../theme/colors.dart';

class DashboardScreen extends StatelessWidget {
  // 1. user 데이터를 전달받을 변수 선언
  final Map<String, dynamic> user;

  // 2. 생성자에서 user 데이터를 필수로 받도록 수정
  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String dateString = DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(
        DateTime.now());
    // 3. 이제 전달받은 user 데이터의 nickname을 사용
    final String nickname = user['nickname'] ?? 'User';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(nickname, dateString),
          const SizedBox(height: 24),
          _buildTodaysOverview(),
          const SizedBox(height: 24),
          _buildGoalsProgress(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          _buildAiRecommendations(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  // ... (이하 _build... 메소드들은 이전과 동일) ...
  Widget _buildHeader(String nickname, String dateString) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('안녕하세요, $nickname님!', style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                  Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(dateString,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysOverview() {
    return AppCard(
      header: const AppCardHeader(title: Row(children: [
        Icon(Icons.pie_chart_outline, color: Colors.blue),
        SizedBox(width: 8),
        Text("Today's Progress")
      ])),
      content: AppCardContent(
        child: Column(
          children: [
            _buildProgressRow('Calories', 1480, 2000, 'kcal'),
            const SizedBox(height: 16),
            _buildProgressRow('Protein', 85, 120, 'g'),
            const SizedBox(height: 16),
            _buildProgressRow('Workouts', 1, 2, ''),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String title, num current, num target, String unit) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            Text('$current / $target $unit',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        AppProgressIndicator(value: current / target),
      ],
    );
  }

  Widget _buildGoalsProgress() {
    return AppCard(
      header: const AppCardHeader(title: Row(children: [
        Icon(Icons.track_changes, color: Colors.green),
        SizedBox(width: 8),
        Text('Weekly Goals')
      ])),
      content: AppCardContent(
        // Row를 Padding으로 감싸서 하단에만 여백을 줍니다.
        child: Padding(
          padding: const EdgeInsets.only(bottom: 28.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGoalItem('70.5kg', 'Weight', 'Goal: 68.0kg', Colors.blue),
              _buildGoalItem('32.1kg', 'Muscle', 'Goal: 33.0kg', Colors.green),
              _buildGoalItem('12.8%', 'Body Fat', 'Goal: 10.0%', Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalItem(String value, String label, String goal, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(
            fontSize: 24, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(goal, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionCard(
            Icons.restaurant_menu, 'Log Meal', 'Track your nutrition',
            Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildActionCard(
            Icons.fitness_center, 'Workout', 'Begin your routine',
            Colors.green)),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle,
      Color color) {
    return AppCard(
      content: AppCardContent(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAiRecommendations() {
    return AppCard(
      header: const AppCardHeader(
        title: Row(children: [
          Icon(Icons.psychology, color: Colors.purple),
          SizedBox(width: 8),
          Text('AI Recommendations')
        ]),
        description: Text('Based on your recent progress'),
      ),
      content: AppCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTipCard(
                '💪 Your protein intake is below target. Consider adding a protein shake.',
                Colors.blue),
            const SizedBox(height: 8),
            _buildTipCard(
                '🎯 Great job on consistency! You\'ve worked out 5 days this week.',
                Colors.green),
            const SizedBox(height: 8),
            _buildTipCard(
                '📈 Your lower body strength has improved. Add more weight to squats.',
                Colors.orange),
            const SizedBox(height: 16),
            AppButton(
              onPressed: () {},
              variant: AppButtonVariant.outline,
              child: const Text('Get Detailed AI Analysis'),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String text, Color color) {
    Color textColor;
    if (color == Colors.blue) {
      textColor = Colors.blue.shade800;
    } else if (color == Colors.green) {
      textColor = Colors.green.shade800;
    } else if (color == Colors.orange) {
      textColor = Colors.orange.shade800;
    } else {
      textColor = color;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 14)),
    );
  }

  Widget _buildRecentActivity() {
    // Column을 사용하므로 const를 제거합니다.
    return AppCard(
      header: const AppCardHeader(
        title: Row(children: [
          Icon(Icons.history, color: Colors.indigo),
          SizedBox(width: 8),
          Text('Recent Activity')
        ]),
      ),
      content: AppCardContent(
        // Text 위젯을 Column으로 감싸줍니다.
        child: Column(
          children: [
            const Text('Activity list goes here...'),
            const SizedBox(height: 25), // <-- 하단 여백을 위한 SizedBox 추가
          ],
        ),
      ),
    );
  }
}