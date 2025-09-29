// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_card.dart';
import '../widgets/app_select.dart';
import '../widgets/app_button.dart';
import '../widgets/app_tabs.dart';
import '../theme/app_theme.dart'; // AppTheme에서 색상 가져오기

// 간단한 데이터 모델 (예시)
class ActivityLog {
  final String type;
  final String title;
  final String details;
  final String time;
  final IconData icon;
  final Color color;

  ActivityLog(this.type, this.title, this.details, this.time, this.icon, this.color);
}

enum ViewMode { overview, calendar }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // --- 상태 변수 ---
  ViewMode _viewMode = ViewMode.overview;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final ValueNotifier<List<ActivityLog>> _selectedEvents;

  // --- Mock 데이터 ---
  final Map<DateTime, List<ActivityLog>> _events = {
    DateTime.utc(2025, 9, 27): [
      ActivityLog('meal', '아침, 점심, 저녁 식단 기록', '총 1605kcal', '08:30~19:45', Icons.restaurant_menu, Colors.orange),
      ActivityLog('workout', '상체 운동 완료', '벤치프레스 외 3종', '18:00', Icons.fitness_center, Colors.blue),
    ],
    DateTime.utc(2025, 9, 25): [
      ActivityLog('meal', '아침, 점심 식단 기록', '총 900kcal', '08:00~13:00', Icons.restaurant_menu, Colors.orange),
    ],
    DateTime.utc(2025, 9, 24): [
      ActivityLog('workout', '하체 운동 완료', '스쿼트 외 4종', '19:30', Icons.fitness_center, Colors.blue),
    ],
  };

  final weeklyData = [
    {'date': "월", 'calories': 1850.0, 'protein': 120.0, 'workout': 45.0},
    {'date': "화", 'calories': 1920.0, 'protein': 115.0, 'workout': 60.0},
    {'date': "수", 'calories': 1780.0, 'protein': 105.0, 'workout': 0.0},
    {'date': "목", 'calories': 1900.0, 'protein': 125.0, 'workout': 50.0},
    {'date': "금", 'calories': 2100.0, 'protein': 140.0, 'workout': 75.0},
    {'date': "토", 'calories': 2200.0, 'protein': 135.0, 'workout': 90.0},
    {'date': "일", 'calories': 1950.0, 'protein': 110.0, 'workout': 30.0},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<ActivityLog> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('기록 분석'),
        actions: [_buildViewModeToggle()],
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _viewMode == ViewMode.overview
          ? _buildOverviewView()
          : _buildCalendarView(),
    );
  }

  Widget _buildViewModeToggle() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ToggleButtons(
        isSelected: [_viewMode == ViewMode.overview, _viewMode == ViewMode.calendar],
        onPressed: (index) {
          setState(() {
            _viewMode = index == 0 ? ViewMode.overview : ViewMode.calendar;
          });
        },
        borderRadius: BorderRadius.circular(8),
        selectedColor: Colors.white,
        fillColor: AppColors.primary,
        constraints: const BoxConstraints(minHeight: 32, minWidth: 80),
        children: const [
          Row(children: [Icon(Icons.bar_chart, size: 16), SizedBox(width: 4), Text('통계')]),
          Row(children: [Icon(Icons.calendar_today, size: 16), SizedBox(width: 4), Text('캘린더')]),
        ],
      ),
    );
  }

  Widget _buildOverviewView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          content: AppCardContent(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('조회 기간'),
                SizedBox(
                  width: 120,
                  child: AppSelect(items: const ['주간', '월간'], value: '주간', onChanged: (val){}),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppTabs(
          tabTitles: const ['칼로리', '단백질', '운동'],
          tabContents: [
            _buildChartCard('주간 칼로리 섭취량', 'calories', Colors.blue),
            _buildChartCard('주간 단백질 섭취량', 'protein', Colors.purple),
            _buildChartCard('주간 운동시간', 'workout', Colors.green),
          ],
        ),
        const SizedBox(height: 16),
        const Text('최근 활동', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...(_events[DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day)] ?? []).map((act) => _buildActivityCard(act)),
      ],
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppCard(
            content: AppCardContent(
              padding: EdgeInsets.zero,
              child: TableCalendar<ActivityLog>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                eventLoader: _getEventsForDay,
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ValueListenableBuilder<List<ActivityLog>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              if (value.isEmpty) {
                return const Center(child: Text('선택된 날짜에 기록이 없습니다.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return _buildActivityCard(value[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, String dataKey, Color color) {
    return AppCard(
      header: AppCardHeader(padding: const EdgeInsets.all(16), title: Text(title)),
      content: AppCardContent(
        padding: const EdgeInsets.only(right: 16, bottom: 16),
        child: SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: weeklyData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value[dataKey] as double)).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.2)),
                  )
                ]
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityLog log) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      content: AppCardContent(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: log.color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(log.icon, color: log.color)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(log.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(log.details, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ])),
            Text(log.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}