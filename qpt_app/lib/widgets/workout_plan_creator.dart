// lib/widgets/workout_plan_creator.dart (Final Translated Version)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise_data.dart'; // exercise_data.dart 모델 파일이 필요합니다.
import '../services/api_service.dart';
import 'app_input.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'app_label.dart';

class WorkoutPlanCreator extends StatefulWidget {
  final VoidCallback? onPlanCreated;
  final Map<String, dynamic>? initialRoutineData; // 루틴 데이터
  
  const WorkoutPlanCreator({
    super.key,
    this.onPlanCreated,
    this.initialRoutineData,
  });

  @override
  State<WorkoutPlanCreator> createState() => _WorkoutPlanCreatorState();
}

class _WorkoutPlanCreatorState extends State<WorkoutPlanCreator> {
  final ApiService _apiService = ApiService();
  final _planNameController = TextEditingController();
  final _searchController = TextEditingController();
  DateTime _planDate = DateTime.now();
  List<ExerciseSet> _exerciseSets = [];
  Exercise? _selectedExercise;
  List<Exercise> _filteredExercises = [];
  List<Exercise> _exerciseLibrary = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterExercises);
    _loadExercises();
    _loadRoutineData();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await _apiService.getExercises();
      if (mounted) {
        setState(() {
          _exerciseLibrary = exercises
              .map((ex) => Exercise(
                    id: ex['exerciseId'].toString(),
                    name: ex['exerciseName'],
                    type: ex['exerciseType'] == 'weight'
                        ? ExerciseType.weight
                        : ExerciseType.cardio,
                    muscleGroups: [], // API doesn't return muscle groups here
                  ))
              .toList();
        });
      }
    } catch (e) {
      print('❌ 운동 목록 로드 실패: $e');
    }
  }

  void _loadRoutineData() {
    if (widget.initialRoutineData == null) return;
    
    final routineData = widget.initialRoutineData!;
    
    // 루틴 이름 설정
    _planNameController.text = routineData['routineName'] ?? '';
    
    // 루틴의 운동들을 ExerciseSet으로 변환
    final exercises = routineData['exercises'] as List<dynamic>? ?? [];
    
    setState(() {
      for (var exerciseData in exercises) {
        final exercise = Exercise(
          id: exerciseData['exerciseId'].toString(),
          name: exerciseData['exerciseName'],
          type: exerciseData['exerciseType'] == 'weight'
              ? ExerciseType.weight
              : ExerciseType.cardio,
          muscleGroups: [],
        );
        
        // 해당 운동의 세트 개수만큼 추가
        final defaultSets = exerciseData['defaultSets'] ?? 3;
        for (int i = 0; i < defaultSets; i++) {
          final targetWeightKg = exerciseData['defaultWeightKg'];
          final targetReps = exerciseData['defaultReps'];
          final targetDuration = exerciseData['defaultDurationMinutes'];
          
          _exerciseSets.add(ExerciseSet(
            id: 'set-${DateTime.now().millisecondsSinceEpoch}-$i',
            exerciseId: exercise.id,
            exerciseName: exercise.name,
            exerciseType: exercise.type,
            setNumber: i + 1,
            targetWeight: targetWeightKg != null
                ? (targetWeightKg is num ? targetWeightKg.toInt() : int.tryParse(targetWeightKg.toString()) ?? 0)
                : 0,
            targetReps: targetReps != null
                ? (targetReps is num ? targetReps.toInt() : int.tryParse(targetReps.toString()) ?? 10)
                : 10,
            targetDuration: targetDuration != null
                ? (targetDuration is num ? targetDuration.toInt() : int.tryParse(targetDuration.toString()) ?? 30)
                : 30,
          ));
        }
      }
    });
    
    print('📚 루틴 로드 완료: ${routineData['routineName']}, ${_exerciseSets.length}개 세트');
  }

  @override
  void dispose() {
    _planNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredExercises = [];
      } else {
        _filteredExercises = _exerciseLibrary.where((ex) => ex.name.toLowerCase().contains(query)).toList();
      }
    });
  }

  void _selectExercise(Exercise exercise) {
    setState(() {
      _selectedExercise = exercise;
      _searchController.clear();
      _filteredExercises = [];
      // 운동을 선택하면 바로 첫 세트를 추가해주는 것도 좋은 UX입니다.
      _addSet();
    });
  }

  void _addSet() {
    if (_selectedExercise == null) return;
    final setNumber = _exerciseSets.where((s) => s.exerciseId == _selectedExercise!.id).length + 1;
    final newSet = ExerciseSet(
      id: 'set-${DateTime.now().millisecondsSinceEpoch}',
      exerciseId: _selectedExercise!.id,
      exerciseName: _selectedExercise!.name,
      exerciseType: _selectedExercise!.type,
      setNumber: setNumber,
    );
    setState(() => _exerciseSets.add(newSet));
  }

  void _removeSet(String setId) {
    setState(() => _exerciseSets.removeWhere((s) => s.id == setId));
  }

  Map<String, List<ExerciseSet>> get _groupedSets {
    final map = <String, List<ExerciseSet>>{};
    for (var set in _exerciseSets) {
      (map[set.exerciseName] ??= []).add(set);
    }
    return map;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _planDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (picked != null && picked != _planDate) setState(() => _planDate = picked);
  }

  Future<void> _handleSavePlan() async {
    if (_exerciseSets.isEmpty || _isSubmitting) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      // API 호출
      await _apiService.createWorkoutPlan({
        'planDate': DateFormat('yyyy-MM-dd').format(_planDate),
        'memo': _planNameController.text.trim().isEmpty
            ? 'Workout Plan'
            : _planNameController.text.trim(),
        'sets': _exerciseSets.map((set) {
          return {
            'exerciseId': int.parse(set.exerciseId),
            'displayOrder': _exerciseSets.indexOf(set) + 1,
            'setNumber': set.setNumber,
            if (set.exerciseType == ExerciseType.weight) ...{
              'targetWeightKg': set.targetWeight,
              'targetReps': set.targetReps,
            } else ...{
              'targetDurationMinutes': set.targetDuration ?? 20,
            },
          };
        }).toList(),
      });
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 운동 계획이 생성되었습니다!')),
        );
        
        // 부모 위젯에 알림
        widget.onPlanCreated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 운동 계획 생성 실패: ${e.toString()}')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 24
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Create Workout Plan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
          ]),
          const SizedBox(height: 24),

          const AppLabel('Plan Name *'),
          AppInput(controller: _planNameController, hintText: 'e.g., Upper Body Day'),
          const SizedBox(height: 16),

          const AppLabel('Plan Date'),
          AppButton(variant: AppButtonVariant.outline, onPressed: () => _selectDate(context), child: Text(DateFormat('yyyy-MM-dd').format(_planDate))),
          const SizedBox(height: 16),

          const AppLabel('Add Exercise'),
          TextField(controller: _searchController, decoration: const InputDecoration(hintText: 'Search for an exercise', prefixIcon: Icon(Icons.search))),
          if (_searchController.text.isNotEmpty && _filteredExercises.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView(children: _filteredExercises.map((ex) => ListTile(title: Text(ex.name), onTap: () => _selectExercise(ex))).toList()),
            ),

          if (_selectedExercise != null && _exerciseSets.where((s) => s.exerciseId == _selectedExercise!.id).isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: AppCard(content: AppCardContent(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Add sets for: ${_selectedExercise!.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
                AppButton(onPressed: _addSet, child: const Text('Add First Set'))
              ]))),
            ),

          if (_exerciseSets.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Current Plan (${_exerciseSets.length} total sets)', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._groupedSets.entries.map((entry) {
              final exerciseName = entry.key;
              final sets = entry.value;
              final exerciseId = sets.first.exerciseId;

              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                header: AppCardHeader(title: Text(exerciseName)),
                content: AppCardContent(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
                  child: Column(
                    children: [
                      ...sets.asMap().entries.map((setEntry) {
                        int index = setEntry.key;
                        ExerciseSet set = setEntry.value;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Text('#${index + 1}'),
                              const SizedBox(width: 8),
                              Expanded(child: AppInput(hintText: 'kg', initialValue: set.targetWeight.toString(), keyboardType: TextInputType.number)),
                              const SizedBox(width: 8),
                              const Text('×'),
                              const SizedBox(width: 8),
                              Expanded(child: AppInput(hintText: 'reps', initialValue: set.targetReps.toString(), keyboardType: TextInputType.number)),
                              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removeSet(set.id)),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      // 각 운동 카드 안에 '세트 추가' 버튼 배치
                      AppButton(
                        onPressed: () {
                          // _selectedExercise를 현재 카드의 운동으로 업데이트하고 세트 추가
                          setState(() => _selectedExercise = _exerciseLibrary.firstWhere((e) => e.id == exerciseId));
                          _addSet();
                        },
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.sm,
                        child: const Text('Add Set'),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],

          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: AppButton(
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                variant: AppButtonVariant.outline,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(
                onPressed: _exerciseSets.isNotEmpty && !_isSubmitting ? _handleSavePlan : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Plan'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}