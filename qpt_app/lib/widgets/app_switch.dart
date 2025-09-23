// lib/widgets/app_switch.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppSwitch extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const AppSwitch({
    super.key,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (bool value) {
        setState(() {
          _value = value;
        });
        widget.onChanged?.call(value);
      },
      // 스타일링
      activeColor: AppColors.primaryForeground,
      activeTrackColor: AppColors.primary,
      inactiveThumbColor: AppColors.mutedForeground,
      inactiveTrackColor: AppColors.muted,
    );
  }
}