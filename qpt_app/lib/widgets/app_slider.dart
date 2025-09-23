// lib/widgets/app_slider.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppSlider extends StatefulWidget {
  final double initialValue;
  final double min;
  final double max;
  final Function(double)? onChanged;

  const AppSlider({
    super.key,
    this.initialValue = 50,
    this.min = 0,
    this.max = 100,
    this.onChanged,
  });

  @override
  State<AppSlider> createState() => _AppSliderState();
}

class _AppSliderState extends State<AppSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _currentValue,
      min: widget.min,
      max: widget.max,
      // 슬라이더를 움직일 때마다 _currentValue를 업데이트
      onChanged: (double value) {
        setState(() {
          _currentValue = value;
        });
        widget.onChanged?.call(value);
      },
      // 스타일링
      activeColor: AppColors.primary,
      inactiveColor: AppColors.muted,
    );
  }
}