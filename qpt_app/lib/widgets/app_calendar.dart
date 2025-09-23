// lib/widgets/app_calendar.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../theme/colors.dart';

// Calendar는 상태(선택된 날짜)가 바뀌어야 하므로 StatefulWidget으로 만듭니다.
class AppCalendar extends StatefulWidget {
  const AppCalendar({super.key});

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  // 달력의 상태를 관리하는 변수들
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      // 필수 속성들
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      
      // 날짜 선택 로직
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay; // 선택된 날짜로 포커스 이동
        });
      },

      // --- 여기부터는 UI 스타일링 ---
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false, // '2 weeks' 같은 포맷 버튼 숨기기
        titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      calendarStyle: CalendarStyle(
        // 오늘 날짜 스타일
        todayDecoration: BoxDecoration(
          color: AppColors.muted,
          shape: BoxShape.circle,
        ),
        todayTextStyle: TextStyle(color: AppColors.mutedForeground),
        
        // 선택된 날짜 스타일
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(color: AppColors.primaryForeground),

        // 주말 날짜 스타일
        weekendTextStyle: TextStyle(color: AppColors.destructive.withOpacity(0.8)),
        
        // 이번 달이 아닌 날짜(outside) 스타일
        outsideTextStyle: TextStyle(color: AppColors.mutedForeground.withOpacity(0.5)),
      ),
    );
  }
}