// lib/widgets/app_collapsible.dart

import 'package:flutter/material.dart';

class AppCollapsible extends StatefulWidget {
  // 누르는 부분에 들어갈 위젯
  final Widget trigger;
  // 펼쳐질 내용에 들어갈 위젯
  final Widget content;
  // 초기 상태 (펼쳐진 상태로 시작할지 여부)
  final bool initialOpen;

  const AppCollapsible({
    super.key,
    required this.trigger,
    required this.content,
    this.initialOpen = false,
  });

  @override
  State<AppCollapsible> createState() => _AppCollapsibleState();
}

class _AppCollapsibleState extends State<AppCollapsible> {
  // 펼쳐짐/접힘 상태를 저장하는 변수
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialOpen;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 누르는 부분 (Trigger)
        // InkWell로 감싸서 탭 이벤트를 받음
        InkWell(
          onTap: _toggleExpanded,
          child: widget.trigger,
        ),
        // 2. 펼쳐지는 내용 (Content)
        // AnimatedCrossFade를 사용해 부드러운 애니메이션 효과를 줌
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8.0), // 내용과 약간의 간격
            child: widget.content,
          ),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}