// lib/widgets/app_toggle_group.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppToggleGroup extends StatefulWidget {
  final List<Widget> children;
  final List<bool> initialSelection;

  const AppToggleGroup({
    super.key,
    required this.children,
    required this.initialSelection,
  }) : assert(children.length == initialSelection.length);

  @override
  State<AppToggleGroup> createState() => _AppToggleGroupState();
}

class _AppToggleGroupState extends State<AppToggleGroup> {
  late List<bool> _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: _isSelected,
      onPressed: (int index) {
        setState(() {
          _isSelected[index] = !_isSelected[index];
        });
      },
      // 스타일링
      borderRadius: BorderRadius.circular(8),
      selectedColor: Colors.white,
      color: AppColors.secondaryForeground,
      fillColor: AppColors.primary,
      selectedBorderColor: AppColors.primary,
      borderColor: AppColors.outlineBorder,
      children: widget.children,
    );
  }
}