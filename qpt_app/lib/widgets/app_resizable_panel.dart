// lib/widgets/app_resizable_panel.dart

import 'package:flutter/material.dart';
import 'package:multi_split_view/multi_split_view.dart';
import '../theme/colors.dart';

class AppResizablePanel extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;

  const AppResizablePanel({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    // 1. 컨트롤러를 생성합니다.
    final controller = MultiSplitViewController(
      areas: List.generate(children.length, (_) => Area()),
    );

    // 2. MultiSplitView의 기본 생성자를 사용합니다.
    return MultiSplitView(
      axis: direction,
      controller: controller,
      // 3. builder의 파라미터 형식을 (BuildContext context, Area area)로 수정합니다.
      // 이 버전에서는 index를 직접 주지 않고, controller에서 찾아야 합니다.
      builder: (BuildContext context, Area area) {
        // 컨트롤러의 areas 리스트에서 현재 area와 동일한 객체의 인덱스를 찾습니다.
        final index = controller.areas.indexOf(area);
        // 찾은 인덱스에 해당하는 위젯을 반환합니다.
        return children[index];
      },
      dividerBuilder: (axis, index, resizable, dragging, highlighted, themeData) {
        return Container(
          color: AppColors.outlineBorder.withOpacity(0.5),
          child: Center(
            child: Icon(
              Icons.drag_indicator,
              size: 16,
              color: AppColors.mutedForeground,
            ),
          ),
        );
      },
    );
  }
}