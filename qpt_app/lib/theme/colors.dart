// lib/theme/colors.dart

import 'package:flutter/material.dart';

// 앱 전체에서 사용할 색상을 정의합니다.
// 나중에 디자이너가 주는 색상 코드로 여기만 수정하면 앱 전체 색상이 바뀝니다.
class AppColors {
  static const Color primary = Colors.black;
  static const Color secondary = Color(0xFFE5E7EB); // Tailwind gray-200
  static const Color destructive = Color(0xFFEF4444); // Tailwind red-500
  static const Color outlineBorder = Color(0xFFD1D5DB); // Tailwind gray-300

  static const Color muted = Color(0xFFF1F5F9); // Tailwind slate-100
  static const Color mutedForeground = Color(0xFF64748B); // Tailwind slate-500
  
  static const Color accent = Color(0xFFF1F5F9); // muted와 동일하게 일단 지정 (Tailwind slate-100)
  static const Color accentForeground = Color(0xFF0F172A); // Tailwind slate-900

  static const Color primaryForeground = Colors.white;
  static const Color secondaryForeground = Color(0xFF1F2937); // Tailwind gray-800
  static const Color destructiveForeground = Colors.white;
}