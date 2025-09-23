// lib/widgets/app_radio_group.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppRadioGroup extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final Function(String?) onValueChanged;

  const AppRadioGroup({
    super.key,
    required this.options,
    this.initialValue,
    required this.onValueChanged,
  });

  @override
  State<AppRadioGroup> createState() => _AppRadioGroupState();
}

class _AppRadioGroupState extends State<AppRadioGroup> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // Column을 사용해 라디오 버튼들을 세로로 나열
    return Column(
      children: widget.options.map((option) {
        // ListTile을 사용하면 라디오 버튼과 텍스트를 깔끔하게 정렬할 수 있습니다.
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: _selectedValue,
          onChanged: (String? value) {
            setState(() {
              _selectedValue = value;
            });
            widget.onValueChanged(value);
          },
          activeColor: AppColors.primary,
        );
      }).toList(),
    );
  }
}