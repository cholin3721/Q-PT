// lib/screens/ai_trainer_screen.dart (수정본)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/app_badge.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../services/api_service.dart';

class AiTrainerScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const AiTrainerScreen({super.key, required this.user});

  @override
  State<AiTrainerScreen> createState() => _AiTrainerScreenState();
}

class _AiTrainerScreenState extends State<AiTrainerScreen> {
  final ApiService _apiService = ApiService();
  
  bool _isGeneratingFeedback = false;
  bool _isLoading = true;
  String _selectedPeriod = "week";
  
  Map<String, dynamic>? _latestFeedback;
  List<Map<String, dynamic>> _feedbackHistory = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    try {
      final feedbacks = await _apiService.getAIFeedbacks();
      if (mounted) {
        setState(() {
          _feedbackHistory = feedbacks;
          _latestFeedback = feedbacks.isNotEmpty ? feedbacks.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print('피드백 로드 실패: $e');
      }
    }
  }

  Future<void> _handleGenerateFeedback() async {
    setState(() => _isGeneratingFeedback = true);
    
    try {
      final response = await _apiService.requestAIFeedback(_selectedPeriod);
      
      if (mounted) {
        setState(() {
          _isGeneratingFeedback = false;
          _latestFeedback = response;
          _feedbackHistory.insert(0, response);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 분석이 완료되었습니다!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingFeedback = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI 분석 실패: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.grey,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          if (_latestFeedback != null) _buildRecommendedNutrition(),
          if (_latestFeedback != null) const SizedBox(height: 24),
          _buildGenerateAnalysisCard(),
          const SizedBox(height: 24),
          if (_latestFeedback != null) _buildLatestFeedbackCard(),
          if (_latestFeedback != null) const SizedBox(height: 24),
          if (_latestFeedback != null) _buildRecommendedExercises(),
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

  Widget _buildRecommendedNutrition() {
    final nutrition = _latestFeedback?['feedbackContent']?['recommendations']?['nutrition'];
    if (nutrition == null) return const SizedBox.shrink();

    final protein = nutrition['protein'] ?? 0;
    final carbs = nutrition['carbs'] ?? 0;
    final fat = nutrition['fat'] ?? 0;
    final calories = nutrition['calories'] ?? 0;

    return AppCard(
      header: const AppCardHeader(
        title: Row(children: [
          Icon(Icons.restaurant, color: Colors.blue),
          SizedBox(width: 8),
          Text('AI Recommended Nutrition')
        ]),
        padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
      ),
      content: AppCardContent(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildNutritionItem('${calories}kcal', 'Calories', Colors.red),
                  _buildNutritionItem('${protein}g', 'Protein', Colors.blue),
                  _buildNutritionItem('${carbs}g', 'Carbs', Colors.green),
                  _buildNutritionItem('${fat}g', 'Fat', Colors.orange),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: () => _applyNutritionGoal(),
                  variant: AppButtonVariant.outline,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_add, size: 18),
                      SizedBox(width: 8),
                      Text('이 영양소를 내 목표로 설정'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyNutritionGoal() async {
    try {
      final feedbackId = _latestFeedback?['feedbackId'];
      if (feedbackId == null) {
        throw Exception('피드백 ID를 찾을 수 없습니다.');
      }

      final result = await _apiService.applyAINutrition(feedbackId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'AI 추천 영양소가 목표로 설정되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('목표 설정 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildNutritionItem(String value, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
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

  Widget _buildLatestFeedbackCard() {
    final content = _latestFeedback?['feedbackContent'];
    final createdAt = _latestFeedback?['createdAt'];
    
    if (content == null) return const SizedBox.shrink();
    
    final analysis = content['analysis'] ?? '분석 결과를 불러올 수 없습니다.';
    final date = createdAt != null ? DateTime.parse(createdAt) : DateTime.now();

    return AppCard(
      header: AppCardHeader(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(children: [
              Icon(Icons.psychology, color: Colors.purple),
              SizedBox(width: 8),
              Text('Latest AI Analysis')
            ]),
            AppBadge(text: DateFormat.yMMMd().format(date), variant: AppBadgeVariant.secondary),
          ],
        ),
      ),
      content: AppCardContent(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Text(
              analysis,
              style: TextStyle(color: Colors.purple.shade800, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedExercises() {
    final exercises = _latestFeedback?['feedbackContent']?['recommendations']?['exercises'];
    if (exercises == null || exercises is! List || exercises.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      header: const AppCardHeader(
        title: Row(children: [
          Icon(Icons.fitness_center, color: Colors.green),
          SizedBox(width: 8),
          Text('AI Recommended Exercises')
        ]),
      ),
      content: AppCardContent(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            children: [
              ...exercises.map<Widget>((exercise) {
                final name = exercise['name'] ?? 'Unknown';
                final type = exercise['type'] ?? 'weight';
                final sets = exercise['sets'] ?? 0;
                final reps = exercise['reps'];
                final weight = exercise['weight'];
                final duration = exercise['duration'];
                final intensity = exercise['intensity'];
                final reason = exercise['reason'] ?? '';
                final isInDb = exercise['isInDatabase'] ?? false;
                
                String details = '';
                if (type == 'cardio' && duration != null) {
                  details = '${duration}분';
                  if (intensity != null) details += ' ($intensity)';
                } else {
                  details = '$sets sets';
                  if (reps != null) details += ' × $reps reps';
                  if (weight != null) details += ' @ ${weight}kg';
                }
                
                // 운동 타입에 따라 색상과 아이콘 결정
                final Color iconColor = type == 'cardio' 
                  ? Colors.orange 
                  : (isInDb ? Colors.green : Colors.blue);
                final IconData iconData = type == 'cardio' 
                  ? Icons.directions_run 
                  : (isInDb ? Icons.fitness_center : Icons.add_circle);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          iconData,
                          color: iconColor,
                          size: 20
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                                if (type == 'cardio')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'CARDIO',
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (!isInDb && type != 'cardio')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              details,
                              style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reason,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: () => _showApplyWorkoutDialog(),
                  variant: AppButtonVariant.defaults,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, size: 18),
                      SizedBox(width: 8),
                      Text('AI 추천대로 운동계획 세팅하기'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showApplyWorkoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI 추천 운동계획 적용'),
        content: const Text('AI가 추천한 운동을 운동계획으로 등록하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('예'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _showDateSelectionDialog();
    }
  }

  Future<void> _showDateSelectionDialog() async {
    final selectedDates = <DateTime>{};
    DateTime focusedDay = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('운동 날짜 선택'),
          content: SizedBox(
            width: 400,
            height: 450,
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 90)),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) => selectedDates.contains(day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      if (selectedDates.contains(selected)) {
                        selectedDates.remove(selected);
                      } else {
                        selectedDates.add(selected);
                      }
                      focusedDay = focused;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '선택된 날짜: ${selectedDates.length}개',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: selectedDates.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      _applyWorkoutPlan(selectedDates.toList());
                    },
              child: const Text('적용'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyWorkoutPlan(List<DateTime> dates) async {
    try {
      final feedbackId = _latestFeedback?['feedbackId'];
      if (feedbackId == null) {
        throw Exception('피드백 ID를 찾을 수 없습니다.');
      }

      final dateStrings = dates.map((d) => DateFormat('yyyy-MM-dd').format(d)).toList();

      final result = await _apiService.applyAIWorkout(feedbackId, dateStrings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'AI 운동계획이 적용되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('운동계획 적용 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}