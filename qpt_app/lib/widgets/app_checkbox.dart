// lib/widgets/app_checkbox.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppCheckbox extends StatefulWidget {
  // 체크박스의 초기 값
  final bool initialValue;
  // 값이 변경될 때 호출될 함수
  final ValueChanged<bool>? onChanged;

  const AppCheckbox({
    super.key,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> {
  // 체크박스의 현재 상태를 저장할 변수
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때 초기 값으로 상태를 설정
    _isChecked = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _isChecked,
      // 체크박스를 누를 때마다 상태를 변경하고 부모에게 알림
      onChanged: (bool? value) {
        if (value != null) {
          // setState를 호출해야 화면이 새로고침되면서 체크 표시가 바뀝니다.
          setState(() {
            _isChecked = value;
          });
          // onChanged 콜백이 있으면 변경된 값을 전달
          widget.onChanged?.call(_isChecked);
        }
      },
      // 스타일링
      activeColor: AppColors.primary, // 체크되었을 때 색상
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // rounded-[4px]
      ),
      side: BorderSide(color: AppColors.outlineBorder),
    );
  }
}