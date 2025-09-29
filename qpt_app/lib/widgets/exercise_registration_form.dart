// lib/widgets/exercise_registration_form.dart

import 'package:flutter/material.dart';
import 'app_select.dart';
import 'app_input.dart';
import 'app_card.dart';
import 'app_button.dart';
import 'app_label.dart';
import 'app_checkbox.dart';

class ExerciseRegistrationForm extends StatefulWidget {
  const ExerciseRegistrationForm({super.key});

  @override
  State<ExerciseRegistrationForm> createState() => _ExerciseRegistrationFormState();
}

class _ExerciseRegistrationFormState extends State<ExerciseRegistrationForm> {
  // --- 상태 변수 ---
  final _exerciseNameController = TextEditingController();
  String? _exerciseType;
  final List<String> _selectedMuscleGroups = [];

  // --- Mock 데이터 ---
  final Map<String, String> _muscleGroups = {
    '1': '가슴', '2': '등', '3': '어깨', '4': '팔',
    '5': '복근', '6': '하체', '7': '전신', '8': '유산소'
  };

  void _handleMuscleGroupToggle(String groupId) {
    setState(() {
      if (_selectedMuscleGroups.contains(groupId)) {
        _selectedMuscleGroups.remove(groupId);
      } else {
        _selectedMuscleGroups.add(groupId);
      }
    });
  }

  bool _isFormValid() {
    return _exerciseNameController.text.isNotEmpty &&
        _exerciseType != null &&
        _selectedMuscleGroups.isNotEmpty;
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('새 운동 등록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
          ]),
          const SizedBox(height: 24),

          // 운동 이름
          const AppLabel('운동 이름 *'),
          const SizedBox(height: 8),
          AppInput(controller: _exerciseNameController, hintText: '예: 벤치프레스, 데드리프트'),
          const SizedBox(height: 16),

          // 운동 종류
          const AppLabel('운동 종류 *'),
          const SizedBox(height: 8),
          AppSelect(
            hintText: '운동 종류를 선택하세요',
            items: const ['웨이트 트레이닝', '유산소 운동'],
            value: _exerciseType,
            onChanged: (value) => setState(() => _exerciseType = value),
          ),
          const SizedBox(height: 16),

          // 운동 부위
          const AppLabel('운동 부위 * (중복 선택 가능)'),
          const SizedBox(height: 8),
          AppCard(
            content: AppCardContent(
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 4,
                children: _muscleGroups.entries.map((entry) {
                  return Row(
                    children: [
                      AppCheckbox(
                        initialValue: _selectedMuscleGroups.contains(entry.key),
                        onChanged: (isChecked) => _handleMuscleGroupToggle(entry.key),
                      ),
                      Text(entry.value),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 선택된 운동 부위 요약
          if (_selectedMuscleGroups.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text('선택된 부위: ${_selectedMuscleGroups.map((id) => _muscleGroups[id]).join(', ')}'),
            ),

          const SizedBox(height: 24),
          // 저장/취소 버튼
          Row(children: [
            Expanded(child: AppButton(onPressed: () => Navigator.of(context).pop(), variant: AppButtonVariant.outline, child: const Text('취소'))),
            const SizedBox(width: 8),
            Expanded(child: AppButton(onPressed: _isFormValid() ? () {} : null, child: const Text('등록하기'))),
          ]),
        ],
      ),
    );
  }
}