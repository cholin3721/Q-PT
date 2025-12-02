// lib/widgets/exercise_registration_form.dart (Translated Version)

import 'package:flutter/material.dart';
import 'app_select.dart';
import 'app_input.dart';
import 'app_card.dart';
import 'app_button.dart';
import 'app_label.dart';
import 'app_checkbox.dart';
import '../services/api_service.dart';

class ExerciseRegistrationForm extends StatefulWidget {
  final VoidCallback? onExerciseAdded;
  
  const ExerciseRegistrationForm({super.key, this.onExerciseAdded});

  @override
  State<ExerciseRegistrationForm> createState() => _ExerciseRegistrationFormState();
}

class _ExerciseRegistrationFormState extends State<ExerciseRegistrationForm> {
  final ApiService _apiService = ApiService();
  
  // --- State Variables ---
  final _exerciseNameController = TextEditingController();
  String? _exerciseType;
  final List<String> _selectedMuscleGroups = [];
  bool _isSubmitting = false;

  // --- Mock Data ---
  final Map<String, String> _muscleGroups = {
    '1': 'Chest', '2': 'Back', '3': 'Shoulders', '4': 'Arms',
    '5': 'Abs', '6': 'Legs', '7': 'Full Body', '8': 'Cardio'
  };

  @override
  void initState() {
    super.initState();
    // Add listener to rebuild on text change for button validation
    _exerciseNameController.addListener(() => setState(() {}));
  }

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
    return _exerciseNameController.text.trim().isNotEmpty &&
        _exerciseType != null &&
        _selectedMuscleGroups.isNotEmpty;
  }

  Future<void> _handleRegister() async {
    if (!_isFormValid() || _isSubmitting) return;
    
    setState(() => _isSubmitting = true);
    
    try {
      // API 호출
      await _apiService.addExercise({
        'exerciseName': _exerciseNameController.text.trim(),
        'exerciseType': _exerciseType == 'Weight Training' ? 'weight' : 'cardio',
        'muscleGroupIds': _selectedMuscleGroups.map((id) => int.parse(id)).toList(),
      });
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 운동이 등록되었습니다!')),
        );
        
        // 부모 위젯에 알림
        widget.onExerciseAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ 운동 등록 실패: ${e.toString()}')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // To prevent keyboard overlap issue
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24, right: 24, top: 24
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Register New Exercise', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
          ]),
          const SizedBox(height: 24),

          // Exercise Name
          const AppLabel('Exercise Name *'),
          const SizedBox(height: 8),
          AppInput(controller: _exerciseNameController, hintText: 'e.g., Bench Press, Deadlift'),
          const SizedBox(height: 16),

          // Exercise Type
          const AppLabel('Exercise Type *'),
          const SizedBox(height: 8),
          AppSelect(
            hintText: 'Select an exercise type',
            items: const ['Weight Training', 'Cardio'],
            value: _exerciseType,
            onChanged: (value) => setState(() => _exerciseType = value),
          ),
          const SizedBox(height: 16),

          // Muscle Groups
          const AppLabel('Muscle Groups * (multiple selections possible)'),
          const SizedBox(height: 8),
          AppCard(
            content: AppCardContent(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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

          // Selected Muscle Groups Summary
          if (_selectedMuscleGroups.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text('Selected groups: ${_selectedMuscleGroups.map((id) => _muscleGroups[id]).join(', ')}'),
            ),

          const SizedBox(height: 24),
          // Save/Cancel Buttons
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
                onPressed: _isFormValid() && !_isSubmitting ? _handleRegister : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Register'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}