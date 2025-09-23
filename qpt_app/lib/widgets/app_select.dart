// lib/widgets/app_select.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppSelect extends StatefulWidget {
  final String? hintText;
  final List<String> items;
  final String? value;
  final Function(String?) onChanged;

  const AppSelect({
    super.key,
    this.hintText,
    required this.items,
    this.value,
    required this.onChanged,
  });

  @override
  State<AppSelect> createState() => _AppSelectState();
}

class _AppSelectState extends State<AppSelect> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedValue,
      hint: widget.hintText != null ? Text(widget.hintText!) : null,
      // React 코드의 스타일을 InputDecoration으로 표현
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outlineBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      // items 목록을 DropdownMenuItem으로 변환
      items: widget.items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      // 값이 변경되었을 때 호출될 함수
      onChanged: (String? newValue) {
        setState(() {
          _selectedValue = newValue;
        });
        widget.onChanged(newValue);
      },
    );
  }
}