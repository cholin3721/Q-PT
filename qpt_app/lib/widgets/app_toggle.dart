// lib/widgets/app_toggle.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppToggle extends StatefulWidget {
  final Widget child;
  final bool initialValue;
  final Function(bool)? onPressed;

  const AppToggle({
    super.key,
    required this.child,
    this.initialValue = false,
    this.onPressed,
  });

  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    // IconButton을 사용하되, 스타일을 정교하게 제어합니다.
    return IconButton(
      isSelected: _isSelected,
      onPressed: () {
        setState(() {
          _isSelected = !_isSelected;
        });
        widget.onPressed?.call(_isSelected);
      },
      // 아이콘(자식 위젯)의 색상
      color: AppColors.mutedForeground,
      // 선택되었을 때 아이콘 색상
      selectedIcon: widget.child,
      // 버튼의 배경 스타일
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent, // 기본 배경은 투명
        foregroundColor: AppColors.mutedForeground, // 기본 아이콘/텍스트 색
        // 선택되었을 때 배경색
        // isSelected 상태에 따라 색을 바꿉니다.
        // `styleFrom`에서는 isSelected 상태를 직접 쓸 수 없으므로,
        // 아래처럼 Container로 감싸서 처리하는 것이 더 명확합니다.
      ),
      icon: widget.child,
    );
  }
}
// 참고: IconButton의 스타일링보다 Container와 InkWell을 조합하는 것이
// React의 data-[state=on] 같은 상태 기반 스타일링을 구현하기에 더 직관적일 수 있습니다.
// 여기서는 IconButton의 isSelected를 활용하는 간단한 예시를 보여드립니다.