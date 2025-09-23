// lib/screens/workout_planner_screen.dart (수정본)

import 'package:flutter/material.dart';
import '../models/workout_data.dart';
import '../theme/colors.dart';
import '../widgets/app_card.dart';
import '../widgets/app_progress_indicator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_badge.dart';

class WorkoutPlannerScreen extends StatefulWidget {
  // 1. user 데이터를 전달받을 변수 선언
  final Map<String, dynamic> user;

  // 2. 생성자에서 user 데이터를 필수로 받도록 수정
  const WorkoutPlannerScreen({super.key, required this.user});

  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen> {
  WorkoutPlan? _activeWorkout;

  final _todaysPlan = WorkoutPlan(
    id: 1,
    name: "Upper Body Strength",
    status: "active",
    totalSets: 12,
    completedSets: 4,
    exercises: [
      Exercise(id: 1, name: "Bench Press", sets: [
        WorkoutSet(id: 1,
            targetWeight: 60,
            targetReps: 10,
            actualWeight: 60,
            actualReps: 10,
            status: SetStatus.completed),
        WorkoutSet(id: 2,
            targetWeight: 60,
            targetReps: 10,
            actualWeight: 60,
            actualReps: 8,
            status: SetStatus.completed),
        WorkoutSet(id: 3, targetWeight: 65, targetReps: 8),
      ]),
      Exercise(id: 2, name: "Incline Dumbbell Press", sets: [
        WorkoutSet(id: 4,
            targetWeight: 25,
            targetReps: 12,
            actualWeight: 25,
            actualReps: 12,
            status: SetStatus.completed),
        WorkoutSet(id: 5,
            targetWeight: 25,
            targetReps: 12,
            actualWeight: 25,
            actualReps: 10,
            status: SetStatus.completed),
        WorkoutSet(id: 6, targetWeight: 25, targetReps: 12),
      ]),
    ],
  );

  void _handleStartWorkout() {
    setState(() {
      _activeWorkout = _todaysPlan;
    });
  }

  void _handleFinishWorkout() {
    setState(() {
      _activeWorkout = null;
    });
  }

  void _handleCompleteSet(WorkoutSet set) {
    setState(() {
      set.status = SetStatus.completed;
      // 실제 앱에서는 actualWeight, actualReps를 입력받아 저장해야 합니다.
      set.actualWeight = set.targetWeight;
      set.actualReps = set.targetReps;
      _todaysPlan.completedSets++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildTodaysOverviewCard(),
          const SizedBox(height: 24),
          _activeWorkout != null
              ? _buildActiveWorkoutView(_activeWorkout!)
              : _buildRoutineTemplatesView(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Text('Workout Planner',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTodaysOverviewCard() {
    final progress = _todaysPlan.completedSets / _todaysPlan.totalSets;
    return AppCard(
      header: AppCardHeader(
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_todaysPlan.name, style: const TextStyle(fontSize: 16)),
          AppBadge(text: _todaysPlan.status,
              variant: _todaysPlan.status == 'active'
                  ? AppBadgeVariant.defaults
                  : AppBadgeVariant.secondary),
        ]),
        description: Text('${_todaysPlan.completedSets} / ${_todaysPlan
            .totalSets} sets completed'),
      ),
      content: AppCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppProgressIndicator(value: progress),
            const SizedBox(height: 16),
            _activeWorkout == null
                ? AppButton(onPressed: _handleStartWorkout,
                child: const Row(mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, size: 16),
                      SizedBox(width: 8),
                      Text('Start Workout')
                    ]))
                : Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('✅ Workout in progress! Track your sets below.',
                  style: TextStyle(color: Colors.green.shade800)),
            ),
            const SizedBox(height: 20), // <-- 이 줄을 추가해서 하단 여백을 줍니다.
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutView(WorkoutPlan workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...workout.exercises.map((exercise) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AppCard(
                header: AppCardHeader(title: Text(exercise.name)),
                content: AppCardContent(
                  child: Column(
                    children: exercise.sets
                        .asMap()
                        .entries
                        .map((entry) {
                      int idx = entry.key;
                      WorkoutSet set = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text('#${idx + 1}',
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Target: ${set.targetWeight}kg × ${set
                                        .targetReps} reps'),
                                    if (set.status == SetStatus.completed)
                                      Text(
                                          'Actual: ${set.actualWeight}kg × ${set
                                              .actualReps} reps',
                                          style: const TextStyle(
                                              color: Colors.green)),
                                  ]),
                            ),
                            if (set.status == SetStatus.completed)
                              const Icon(
                                  Icons.check_circle, color: Colors.green)
                            else
                              Row(children: [
                                IconButton(icon: const Icon(
                                    Icons.check, color: Colors.green),
                                    onPressed: () => _handleCompleteSet(set)),
                                IconButton(icon: const Icon(
                                    Icons.close, color: Colors.red),
                                    onPressed: () {}),
                              ]),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            )).toList(),
        const SizedBox(height: 16),
        AppButton(onPressed: _handleFinishWorkout,
            child: const Text('Finish Workout')),
      ],
    );
  }

  Widget _buildRoutineTemplatesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Start Routines',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildRoutineCard('Upper Body', 4, 12),
            _buildRoutineCard('Lower Body', 5, 15),
          ],
        )
      ],
    );
  }


  Widget _buildRoutineCard(String name, int exercises, int sets) {
    // AppCard 대신 Container를 직접 사용해서 레이아웃을 완전히 제어합니다.
    return Container(
      // AppCard의 스타일을 그대로 가져옵니다.
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outlineBorder),
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.all(16.0), // 카드 안쪽 여백
      child: Column(
        // 이제 이 Column은 Container가 주는 공간 전체를 차지하므로,
        // mainAxisAlignment가 완벽하게 작동합니다.
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$exercises exercises • $sets sets',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          AppButton(
              onPressed: () {},
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              child: const Text('Load Routine')),
        ],
      ),
    );
  }
}