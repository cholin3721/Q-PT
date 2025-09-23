// lib/widgets/app_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/colors.dart'; // 우리가 만든 색상 파일 가져오기

class AppChart extends StatelessWidget {
  const AppChart({super.key});

  @override
  Widget build(BuildContext context) {
    // 차트의 가로세로 비율을 1.7:1로 설정
    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          // 그리드(격자) 스타일
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppColors.outlineBorder,
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => const FlLine(
              color: AppColors.outlineBorder,
              strokeWidth: 1,
            ),
          ),
          // 축 제목(라벨) 스타일
          titlesData: const FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1, // X축 간격
            )),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 10, // Y축 간격
            )),
          ),
          // 차트 테두리 스타일
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.outlineBorder),
          ),
          // 실제 그래프 선 데이터
          lineBarsData: [
            LineChartBarData(
              spots: const [
                // (x, y) 좌표 데이터
                FlSpot(0, 30),
                FlSpot(2, 40),
                FlSpot(4, 35),
                FlSpot(6, 50),
                FlSpot(8, 45),
                FlSpot(10, 60),
                FlSpot(11, 55),
              ],
              isCurved: true, // 선을 부드럽게
              color: AppColors.primary, // 우리 테마 색상 사용!
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false), // 데이터 포인트 점 숨기기
              // 선 아래 영역 색칠하기
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}