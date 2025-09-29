// lib/widgets/workout_plan_creator.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/exercise_data.dart';
import 'app_input.dart';
import 'app_button.dart';
import 'app_card.dart';
import 'app_label.dart';
import 'app_badge.dart';

class WorkoutPlanCreator extends StatefulWidget {
  const WorkoutPlanCreator({super.key});

  @override
  State<WorkoutPlanCreator> createState() => _WorkoutPlanCreatorState();
}

class _WorkoutPlanCreatorState extends State<WorkoutPlanCreator> {
  final _planNameController = TextEditingController();
  final _searchController = TextEditingController();
  DateTime _planDate = DateTime.now();
  List<ExerciseSet> _exerciseSets = [];
  Exercise? _selectedExercise;
  List<Exercise> _filteredExercises = [];

  final List<Exercise> _exerciseLibrary = [
    Exercise(id: "1", name: "벤치프레스", type: ExerciseType.weight, muscleGroups: ["가슴"]),
    Exercise(id: "2", name: "스쿼트", type: ExerciseType.weight, muscleGroups: ["하체"]),
    Exercise(id: "3", name: "데드리프트", type: ExerciseType.weight, muscleGroups: ["등", "하체"]),
    Exercise(id: "4", name: "런닝머신", type: ExerciseType.cardio, muscleGroups: ["유산소"]),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterExercises);
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
      _filteredExercises = _exerciseLibrary.where((ex) => ex.name.toLowerCase().contains(query)).toList();
    });
  }

  void _selectExercise(Exercise exercise) {
    setState(() {
      _selectedExercise = exercise;
      _searchController.clear();
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
      (map[set.exerciseId] ??= []).add(set);
    }
    return map;
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _planDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (picked != null && picked != _planDate) setState(() => _planDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('운동 계획 생성', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
          ]),
          const SizedBox(height: 24),
          
          const AppLabel('계획 이름 *'),
          AppInput(controller: _planNameController, hintText: '예: 상체 운동'),
          const SizedBox(height: 16),

          const AppLabel('운동 날짜'),
          AppButton(variant: AppButtonVariant.outline, onPressed: () => _selectDate(context), child: Text(DateFormat('yyyy-MM-dd').format(_planDate))),
          const SizedBox(height: 16),
          
          const AppLabel('운동 추가'),
          TextField(controller: _searchController, decoration: const InputDecoration(hintText: '운동을 검색하세요', prefixIcon: Icon(Icons.search))),
          if (_searchController.text.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView(children: _filteredExercises.map((ex) => ListTile(title: Text(ex.name), onTap: () => _selectExercise(ex))).toList()),
            ),
          
          if (_selectedExercise != null)
            AppCard(content: AppCardContent(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(_selectedExercise!.name), AppButton(onPressed: _addSet, child: const Text('세트 추가'))]))),
          
          if (_exerciseSets.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('운동 계획 (${_exerciseSets.length}개 세트)', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._groupedSets.entries.map((entry) => AppCard(
              header: AppCardHeader(title: Text(entry.value.first.exerciseName)),
              content: AppCardContent(
                child: Column(
                  children: entry.value.asMap().entries.map((setEntry) {
                    int index = setEntry.key;
                    ExerciseSet set = setEntry.value;
                    return Row(
                      children: [
                        Text('#${index + 1}'),
                        const SizedBox(width: 8),
                        Expanded(child: AppInput(hintText: 'kg', initialValue: set.targetWeight.toString())),
                        const SizedBox(width: 8),
                        const Text('×'),
                        const SizedBox(width: 8),
                        Expanded(child: AppInput(hintText: 'reps', initialValue: set.targetReps.toString())),
                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removeSet(set.id)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            )),
          ],

          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: AppButton(onPressed: () => Navigator.of(context).pop(), variant: AppButtonVariant.outline, child: const Text('취소'))),
            const SizedBox(width: 8),
            Expanded(child: AppButton(onPressed: () {}, child: const Text('계획 저장'))),
          ]),
        ],
      ),
    );
  }
}