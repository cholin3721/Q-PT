// lib/screens/ai_trainer_screen.dart (수정본)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/feedback_data.dart';
import '../theme/colors.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';

class AiTrainerScreen extends StatefulWidget {
  // 1. user 데이터를 전달받을 변수 선언
  final Map<String, dynamic> user;

  // 2. 생성자에서 user 데이터를 필수로 받도록 수정
  const AiTrainerScreen({super.key, required this.user});

  @override
  State<AiTrainerScreen> createState() => _AiTrainerScreenState();
}

class _AiTrainerScreenState extends State<AiTrainerScreen> {
  // --- 상태 변수 ---
  bool _isGeneratingFeedback = false;
  String _selectedPeriod = "week";

  // --- Mock 데이터 ---
  final List<FeedbackHistory> _feedbackHistory = [
    FeedbackHistory(
      id: 1, type: "weekly", date: DateTime(2024, 1, 15),
      analysis: "Excellent progress this week! Your consistency with workouts has improved significantly.",
      recommendations: [
        "Increase protein intake by 15g daily", "Add 5kg to your bench press", "Add one cardio session"
      ],
      metrics: FeedbackMetrics(workoutConsistency: 85, nutritionScore: 78, progressRate: 92),
    ),
    FeedbackHistory(
      id: 2, type: "monthly", date: DateTime(2024, 1, 1),
      analysis: "Your December performance shows strong dedication.",
      recommendations: ["Transition to intermediate workout routine", "Focus on compound movements", "Track sleep quality"],
      metrics: FeedbackMetrics(workoutConsistency: 82, nutritionScore: 74, progressRate: 88),
    ),
  ];

  void _handleGenerateFeedback() async {
    setState(() => _isGeneratingFeedback = true);
    await Future.delayed(const Duration(seconds: 3)); // Mock AI 분석 시간
    setState(() => _isGeneratingFeedback = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New AI feedback would be generated here!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestFeedback = _feedbackHistory[0];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildGenerateAnalysisCard(),
          const SizedBox(height: 24),
          _buildLatestFeedbackCard(latestFeedback),
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
          Text('AI Personal Trainer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Your intelligent fitness companion analyzing your progress', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return AppCard(
      // AppCardHeader에 새로 만든 padding 속성을 사용합니다.
      header: const AppCardHeader(
        title: Row(children: [
          Icon(Icons.trending_up, color: Colors.blue),
          SizedBox(width: 8),
          Text('Current Performance')
        ]),
        // 하단 여백을 16 대신 8로 줄입니다.
        padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
      ),
      content: AppCardContent(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              _buildStatItem('4', 'Workouts This Week', Colors.green),
              _buildStatItem('1850', 'Avg Daily Calories', Colors.blue),
              _buildStatItem('95g', 'Daily Protein', Colors.orange),
              _buildStatItem('12%', 'Strength Increase', Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildGenerateAnalysisCard() {
    return AppCard(
      content: AppCardContent(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
                ),
                child: const Icon(Icons.psychology, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Get AI Analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Analyze your recent $_selectedPeriod\ly data for personalized insights',
                textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    onPressed: () => setState(() => _selectedPeriod = "week"),
                    variant: _selectedPeriod == "week" ? AppButtonVariant.defaults : AppButtonVariant.outline,
                    size: AppButtonSize.sm, child: const Text('Weekly'),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    onPressed: () => setState(() => _selectedPeriod = "month"),
                    variant: _selectedPeriod == "month" ? AppButtonVariant.defaults : AppButtonVariant.outline,
                    size: AppButtonSize.sm, child: const Text('Monthly'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppButton(
                onPressed: _isGeneratingFeedback ? null : _handleGenerateFeedback,
                child: _isGeneratingFeedback
                    ? const Row(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        SizedBox(width: 12),
                        Text('Analyzing Your Data...'),
                      ])
                    : Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.auto_awesome, size: 16),
                        const SizedBox(width: 8),
                        Text('Generate ${_selectedPeriod[0].toUpperCase()}${_selectedPeriod.substring(1)}ly Analysis'),
                      ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

// lib/screens/ai_trainer_screen.dart

  Widget _buildLatestFeedbackCard(FeedbackHistory feedback) {
    return AppCard(
      header: AppCardHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [Icon(Icons.message_outlined, color: Colors.green), SizedBox(width: 8), Text('Latest Analysis')]),
            AppBadge(text: DateFormat.yMMMd().format(feedback.date), variant: AppBadgeVariant.secondary),
          ],
        ),
      ),
      content: AppCardContent(
        // 1. Column 전체를 Padding 위젯으로 감싸줍니다.
        child: Padding(
          // 2. only(bottom: ...)을 사용해 아래쪽에만 16만큼 여백을 줍니다.
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(feedback.analysis, style: TextStyle(color: Colors.blue.shade800)),
              ),

              // 3. 요소들 사이의 SizedBox는 원하는 만큼 유지하거나 조절할 수 있습니다.
              const SizedBox(height: 16),
              const Text('AI Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              ...feedback.recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.track_changes, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rec)),
                ]),
              )),

              const SizedBox(height: 16), // AI 추천과 통계 사이 간격

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${feedback.metrics.workoutConsistency}%', 'Consistency', Colors.blue),
                  _buildStatItem('${feedback.metrics.nutritionScore}%', 'Nutrition', Colors.green),
                  _buildStatItem('${feedback.metrics.progressRate}%', 'Progress', Colors.purple),
                ],
              ),
              // 4. Column 맨 마지막에 있던 SizedBox는 이제 Padding이 처리하므로 필요 없습니다.
            ],
          ),
        ),
      ),
    );
  }
}