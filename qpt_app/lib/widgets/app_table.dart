// lib/widgets/app_table.dart

import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;

  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      // 스타일링
      headingRowColor: MaterialStateProperty.all(AppColors.muted),
      columnSpacing: 32,
      columns: columns.map((col) {
        // 컬럼 헤더 생성
        return DataColumn(
          label: Text(
            col,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
      rows: rows.map((row) {
        // 각 데이터 행 생성
        return DataRow(
          cells: row.map((cell) {
            // 각 행의 셀 생성
            return DataCell(Text(cell));
          }).toList(),
        );
      }).toList(),
    );
  }
}