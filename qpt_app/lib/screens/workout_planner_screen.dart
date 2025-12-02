// lib/screens/workout_planner_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout_data.dart';
import '../widgets/app_card.dart';
import '../widgets/app_progress_indicator.dart';
import '../widgets/app_button.dart';
import '../widgets/app_badge.dart';
import '../widgets/exercise_registration_form.dart'; // 운동 등록 폼
import '../widgets/workout_plan_creator.dart';    // 운동 계획 생성 폼
import '../services/api_service.dart';

class WorkoutPlannerScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const WorkoutPlannerScreen({super.key, required this.user});

  @override
  State<WorkoutPlannerScreen> createState() => _WorkoutPlannerScreenState();
}

class _WorkoutPlannerScreenState extends State<WorkoutPlannerScreen> {
  final ApiService _apiService = ApiService();
  
  WorkoutPlan? _activeWorkout;
  WorkoutPlan? _todaysPlan;
  bool _isLoading = true;
  List<Map<String, dynamic>> _exerciseLibrary = [];
  List<Map<String, dynamic>> _routines = []; // 루틴 목록
  
  // 주간 통계
  int _weeklyWorkoutDays = 0;
  int _weeklyTotalTime = 0;
  int _weeklySetsCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadTodaysWorkout();
    _loadExerciseLibrary();
    _loadWeeklyStats();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    try {
      final routines = await _apiService.getRoutines();
      if (mounted) {
        setState(() {
          _routines = routines;
        });
      }
      print('📚 루틴 목록 로드: ${routines.length}개');
    } catch (e) {
      print('❌ 루틴 목록 로드 실패: $e');
    }
  }

  Future<void> _loadTodaysWorkout() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final workoutData = await _apiService.getWorkoutPlan(today);
      
      if (workoutData['planId'] != null && workoutData['status'] != 'none') {
        // API 응답을 WorkoutPlan 모델로 변환
        final plan = _parseWorkoutPlan(workoutData);
        
        if (mounted) {
          setState(() {
            _todaysPlan = plan;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _todaysPlan = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('❌ 운동 계획 로드 실패: $e');
      if (mounted) {
        setState(() {
          _todaysPlan = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadExerciseLibrary() async {
    try {
      final exercises = await _apiService.getExercises();
      if (mounted) {
        setState(() {
          _exerciseLibrary = exercises;
        });
      }
    } catch (e) {
      print('❌ 운동 목록 로드 실패: $e');
    }
  }

  Future<void> _loadWeeklyStats() async {
    try {
      final now = DateTime.now();
      int workoutDays = 0;
      int totalTime = 0;
      int setsCompleted = 0;
      
      // 최근 7일간의 데이터 조회
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dateString = DateFormat('yyyy-MM-dd').format(date);
        
        try {
          final workoutData = await _apiService.getWorkoutPlan(dateString);
          
          if (workoutData['planId'] != null && workoutData['status'] != 'none') {
            workoutDays++;
            
            // 세트 데이터 집계
            if (workoutData['sets'] != null) {
              final sets = workoutData['sets'] as List;
              totalTime += sets.length * 3; // 세트당 3분
              setsCompleted += sets.where((s) => s['status'] == 'completed').length;
            }
          }
        } catch (e) {
          // 해당 날짜에 데이터가 없으면 무시
        }
      }
      
      if (mounted) {
        setState(() {
          _weeklyWorkoutDays = workoutDays;
          _weeklyTotalTime = totalTime;
          _weeklySetsCompleted = setsCompleted;
        });
      }
      
      print('📊 주간 통계: $workoutDays일, ${totalTime}분, $setsCompleted세트');
    } catch (e) {
      print('❌ 주간 통계 로드 실패: $e');
    }
  }

  WorkoutPlan _parseWorkoutPlan(Map<String, dynamic> data) {
    // 운동별로 세트를 그룹화
    final Map<int, List<WorkoutSet>> exerciseSetsMap = {};
    final Map<int, String> exerciseNamesMap = {};
    
    int totalSets = 0;
    int completedSets = 0;
    
    for (var setData in data['sets']) {
      final exerciseId = setData['exerciseId'];
      final exerciseName = setData['exerciseName'];
      
      exerciseNamesMap[exerciseId] = exerciseName;
      
      final set = WorkoutSet(
        id: setData['setId'],
        targetWeight: _safeDouble(setData['targetWeightKg']),
        targetReps: setData['targetReps'],
        actualWeight: _safeDouble(setData['actualWeightKg']),
        actualReps: setData['actualReps'],
        status: _parseSetStatus(setData['status']),
      );
      
      if (!exerciseSetsMap.containsKey(exerciseId)) {
        exerciseSetsMap[exerciseId] = [];
      }
      exerciseSetsMap[exerciseId]!.add(set);
      
      totalSets++;
      if (set.status == SetStatus.completed) {
        completedSets++;
      }
    }
    
    // Exercise 객체 생성
    final exercises = exerciseSetsMap.entries.map((entry) {
      return Exercise(
        id: entry.key,
        name: exerciseNamesMap[entry.key]!,
        sets: entry.value,
      );
    }).toList();
    
    return WorkoutPlan(
      id: data['planId'],
      name: data['memo'] ?? 'Workout Plan',
      status: data['status'],
      totalSets: totalSets,
      completedSets: completedSets,
      exercises: exercises,
    );
  }

  double? _safeDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  SetStatus _parseSetStatus(String? status) {
    switch (status) {
      case 'completed':
        return SetStatus.completed;
      case 'skipped':
        return SetStatus.skipped;
      default:
        return SetStatus.pending;
    }
  }

  // --- 로직 함수들 ---
  void _handleStartWorkout() => setState(() => _activeWorkout = _todaysPlan);
  void _handleFinishWorkout() => setState(() => _activeWorkout = null);

  Future<void> _handleCompleteSet(WorkoutSet set) async {
    try {
      // API 호출
      await _apiService.updateWorkoutSet(set.id, {
        'status': 'completed',
        'actualWeightKg': set.targetWeight,
        'actualReps': set.targetReps,
      });
      
      // UI 업데이트
    setState(() {
      set.status = SetStatus.completed;
      set.actualWeight = set.targetWeight;
      set.actualReps = set.targetReps;
        _todaysPlan!.completedSets++;
        _weeklySetsCompleted++; // 주간 통계 업데이트
      });
      
      print('✅ 세트 완료: Set #${set.id}');
    } catch (e) {
      print('❌ 세트 업데이트 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('세트 업데이트 실패: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleSkipSet(WorkoutSet set) async {
    try {
      // API 호출
      await _apiService.updateWorkoutSet(set.id, {
        'status': 'skipped',
      });
      
      // UI 업데이트
      setState(() {
        set.status = SetStatus.skipped;
      });
      
      print('❌ 세트 스킵: Set #${set.id}');
    } catch (e) {
      print('❌ 세트 업데이트 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('세트 업데이트 실패: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleAddSet(Exercise exercise) async {
    // 마지막 세트의 값을 가져와서 기본값으로 사용
    final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;
    final defaultWeight = lastSet?.targetWeight ?? 0;
    final defaultReps = lastSet?.targetReps ?? 10;

    try {
      // API 호출
      final response = await _apiService.addSetToPlan(_todaysPlan!.id, {
        'exerciseId': exercise.id,
        'targetWeightKg': defaultWeight,
        'targetReps': defaultReps,
      });

      // 새 세트를 UI에 추가
      final newSet = WorkoutSet(
        id: response['setId'],
        targetWeight: _safeDouble(response['targetWeightKg']),
        targetReps: response['targetReps'],
        status: SetStatus.pending,
      );

      setState(() {
        exercise.sets.add(newSet);
        _todaysPlan!.totalSets++;
      });

      print('✅ 세트 추가: ${exercise.name} - Set #${exercise.sets.length}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${exercise.name}에 세트가 추가되었습니다!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ 세트 추가 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('세트 추가 실패: ${e.toString()}')),
      );
    }
  }

  void _showAddExerciseDialog() {
    int? selectedExerciseId;
    int numberOfSets = 3;
    double weight = 0;
    int reps = 10;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Exercise'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Exercise', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: selectedExerciseId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _exerciseLibrary.map((exercise) {
                    return DropdownMenuItem<int>(
                      value: exercise['exerciseId'],
                      child: Text(exercise['exerciseName']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedExerciseId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                const Text('Number of Sets', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (numberOfSets > 1) {
                          setDialogState(() => numberOfSets--);
                        }
                      },
                    ),
                    Text('$numberOfSets', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setDialogState(() => numberOfSets++);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Weight (kg)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    weight = double.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Reps', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onChanged: (value) {
                    reps = int.tryParse(value) ?? 10;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedExerciseId == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      _handleAddExercise(selectedExerciseId!, numberOfSets, weight, reps);
                    },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAddExercise(int exerciseId, int numberOfSets, double weight, int reps) async {
    try {
      // 운동 정보 찾기
      final exerciseData = _exerciseLibrary.firstWhere(
        (ex) => ex['exerciseId'] == exerciseId,
      );

      // 여러 세트를 한번에 추가
      final List<WorkoutSet> newSets = [];
      for (int i = 0; i < numberOfSets; i++) {
        final response = await _apiService.addSetToPlan(_todaysPlan!.id, {
          'exerciseId': exerciseId,
          'targetWeightKg': weight,
          'targetReps': reps,
        });

        newSets.add(WorkoutSet(
          id: response['setId'],
          targetWeight: _safeDouble(response['targetWeightKg']),
          targetReps: response['targetReps'],
          status: SetStatus.pending,
        ));
      }

      // UI 업데이트
      setState(() {
        final newExercise = Exercise(
          id: exerciseId,
          name: exerciseData['exerciseName'],
          sets: newSets,
        );
        _todaysPlan!.exercises.add(newExercise);
        _todaysPlan!.totalSets += numberOfSets;
      });

      print('✅ 운동 추가: ${exerciseData['exerciseName']} - $numberOfSets 세트');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${exerciseData['exerciseName']}이(가) 추가되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ 운동 추가 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('운동 추가 실패: ${e.toString()}')),
        );
      }
    }
  }

  void _showExerciseRegistrationForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ExerciseRegistrationForm(
            onExerciseAdded: () {
              // 운동 목록 새로고침
              _loadExerciseLibrary();
            },
          ),
        ),
      ),
    );
  }

  void _showWorkoutPlanCreator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: WorkoutPlanCreator(
            onPlanCreated: () {
              // 운동 계획 새로고침
              _loadTodaysWorkout();
              _loadWeeklyStats();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
                if (_todaysPlan != null)
                  _buildTodaysOverviewCard()
                else
                  _buildNoWorkoutCard(),
          const SizedBox(height: 24),
          if (_activeWorkout != null)
            _buildActiveWorkoutView(_activeWorkout!)
                else if (_todaysPlan != null)
            _buildRoutineTemplatesView(),
          const SizedBox(height: 24),
          _buildExerciseLibraryCard(),
          const SizedBox(height: 24),
                if (_todaysPlan != null) _buildWeeklyProgressCard(),
              ],
            ),
    );
  }

  Widget _buildNoWorkoutCard() {
    return AppCard(
      header: const AppCardHeader(
        title: Text('오늘의 운동 계획', style: TextStyle(fontSize: 16)),
      ),
      content: AppCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  '오늘 등록된 운동 계획이 없습니다',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            AppButton(
              onPressed: _showWorkoutPlanCreator,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 8),
                  Text('운동 계획 만들기'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- UI 빌더 메소드들 ---
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workout Planner', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          // 여기에 날짜 선택 기능 등을 추가할 수 있습니다.
        ],
      ),
    );
  }

  Widget _buildTodaysOverviewCard() {
    if (_todaysPlan == null) return const SizedBox();
    
    final progress = _todaysPlan!.totalSets > 0
        ? _todaysPlan!.completedSets / _todaysPlan!.totalSets
        : 0.0;
    
    return AppCard(
      header: AppCardHeader(
        title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_todaysPlan!.name, style: const TextStyle(fontSize: 16)),
          AppBadge(
            text: _todaysPlan!.status,
            variant: _todaysPlan!.status == 'active'
                ? AppBadgeVariant.defaults
                : AppBadgeVariant.secondary,
          ),
        ]),
        description: Text('${_todaysPlan!.completedSets} / ${_todaysPlan!.totalSets} sets completed'),
      ),
      content: AppCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppProgressIndicator(value: progress),
            const SizedBox(height: 16),
            if (_activeWorkout == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    onPressed: _handleStartWorkout,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow, size: 16),
                        SizedBox(width: 8),
                        Text('Start Workout'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              )
            else
              Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Container(
              padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '✅ Workout in progress! Track your sets below.',
                      style: TextStyle(color: Colors.green.shade800),
                    ),
                  ),
                  const SizedBox(height: 20),
              ],
    ),
        ],
      ),
      ),
    );
  }

  Widget _buildActiveWorkoutView(WorkoutPlan workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...workout.exercises.map((exercise) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: AppCard(
            header: AppCardHeader(title: Text(exercise.name)),
            content: AppCardContent(
              child: Column(
                children: [
                  ...exercise.sets.asMap().entries.map((entry) {
                  int idx = entry.key;
                  WorkoutSet set = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Text('#${idx + 1}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Target: ${set.targetWeight}kg × ${set.targetReps} reps'),
                            if (set.status == SetStatus.completed)
                              Text('Actual: ${set.actualWeight}kg × ${set.actualReps} reps', style: const TextStyle(color: Colors.green)),
                          ]),
                        ),
                        if (set.status == SetStatus.completed)
                          const Icon(Icons.check_circle, color: Colors.green)
                          else if (set.status == SetStatus.skipped)
                            const Icon(Icons.cancel, color: Colors.red)
                        else
                          Row(children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => _handleCompleteSet(set),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _handleSkipSet(set),
                              ),
                          ]),
                      ],
                    ),
                  );
                }).toList(),
                  const SizedBox(height: 8),
                  AppButton(
                    onPressed: () => _handleAddSet(exercise),
                    variant: AppButtonVariant.outline,
                    size: AppButtonSize.sm,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 4),
                        Text('Add Set'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
        const SizedBox(height: 16),
        AppButton(
          onPressed: _showAddExerciseDialog,
          variant: AppButtonVariant.outline,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('Add Exercise'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AppButton(onPressed: _handleFinishWorkout, child: const Text('Finish Workout')),
      ],
    );
  }

  Widget _buildRoutineTemplatesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Quick Start Routines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            AppButton(
              onPressed: _showWorkoutPlanCreator,
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              child: const Row(children: [Icon(Icons.add, size: 16), SizedBox(width: 4), Text('Create')]),
            )
          ],
        ),
        const SizedBox(height: 16),
        if (_routines.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('루틴을 불러오는 중...', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
        GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: _routines.map((routine) {
              return _buildRoutineCard(
                context,
                routine['routineName'] ?? 'Routine',
                routine['exerciseCount'] ?? 0,
                routine['totalSets'] ?? 0,
                routine['routineId'],
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildRoutineCard(BuildContext context, String name, int exercises, int sets, int routineId) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth - 48) / 2;
    final double cardHeight = cardWidth;

    return AppCard(
      content: AppCardContent(
        child: SizedBox(
          height: cardHeight - 4,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('$exercises exercises • $sets sets', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                AppButton(
                  onPressed: () => _loadRoutineIntoPlan(routineId),
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.sm,
                  child: const Text('Load Routine'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadRoutineIntoPlan(int routineId) async {
    try {
      final routineDetail = await _apiService.getRoutineDetail(routineId);
      
      if (mounted) {
        // WorkoutPlanCreator 모달 열고 루틴 데이터 전달
        _showWorkoutPlanCreatorWithRoutine(routineDetail);
      }
    } catch (e) {
      print('❌ 루틴 로드 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('루틴 로드 실패: ${e.toString()}')),
      );
    }
  }

  void _showWorkoutPlanCreatorWithRoutine(Map<String, dynamic>? routineData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: WorkoutPlanCreator(
            initialRoutineData: routineData, // 루틴 데이터 전달
            onPlanCreated: () {
              _loadTodaysWorkout();
              _loadWeeklyStats();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseLibraryCard() {
    final displayExercises = _exerciseLibrary.take(4).toList();
    
    return AppCard(
      header: const AppCardHeader(title: Text('Exercise Library')),
      content: AppCardContent(
        child: Column(
          children: [
            if (displayExercises.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('운동 목록을 불러오는 중...', style: TextStyle(color: Colors.grey)),
              )
            else
            GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: displayExercises
                    .map((ex) => AppButton(
                          onPressed: () {},
                          variant: AppButtonVariant.outline,
                          size: AppButtonSize.sm,
                          child: Text(ex['exerciseName'] ?? 'Unknown'),
                        ))
                    .toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _showAllExercises,
                  child: Text('전체 ${_exerciseLibrary.length}개 운동 보기 →'),
                ),
                AppButton(
                  onPressed: _showExerciseRegistrationForm,
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.outline,
                  child: const Row(children: [
                    Icon(Icons.add, size: 14),
                    SizedBox(width: 4),
                    Text('Add Exercise'),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void _showAllExercises() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'All Exercises',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  itemCount: _exerciseLibrary.length,
                  itemBuilder: (context, index) {
                    final exercise = _exerciseLibrary[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            exercise['exerciseType'] == 'weight' 
                                ? Icons.fitness_center 
                                : Icons.directions_run,
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(exercise['exerciseName'] ?? 'Unknown'),
                        subtitle: Text(
                          exercise['exerciseType'] == 'weight' ? 'Weight Training' : 'Cardio',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // 운동 상세 정보 또는 추가 기능
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    final progress = _weeklyWorkoutDays / 7.0;
    final totalHours = (_weeklyTotalTime / 60.0).toStringAsFixed(1);
    
    return AppCard(
      header: const AppCardHeader(title: Text("This Week's Progress")),
      content: AppCardContent(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Workouts Completed'),
                Text('$_weeklyWorkoutDays / 7', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            AppProgressIndicator(value: progress),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(totalHours, 'Total Hours', Colors.blue),
                _buildStatItem('$_weeklySetsCompleted', 'Sets Completed', Colors.green),
                _buildStatItem('${_weeklyTotalTime}m', 'Total Minutes', Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}