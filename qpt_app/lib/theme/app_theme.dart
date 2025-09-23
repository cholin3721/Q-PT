// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

// 모든 색상 정의
class AppColors {
  static const Color primary = Color(0xFF030213);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFFF0F0F8);
  static const Color secondaryForeground = Color(0xFF030213);
  static const Color muted = Color(0xFFECECF0);
  static const Color mutedForeground = Color(0xFF717182);
  static const Color accent = Color(0xFFE9EBEF);
  static const Color accentForeground = Color(0xFF030213);
  static const Color destructive = Color(0xFFD4183D);
  static const Color border = Color.fromRGBO(0, 0, 0, 0.1);
  static const Color background = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
}

// 앱 전체의 ThemeData를 정의
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    fontFamily: 'Pretendard', // (pubspec.yaml에 폰트 추가 필요)

    // 카드 테마
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // --radius-xl
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),

    // 버튼 테마
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // --radius-md
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    
    // 텍스트 테마
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold), // h1
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // h2
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w500), // h3
      bodyLarge: TextStyle(fontSize: 16), // p
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // label, button
    ),
    
    // 입력창 테마
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      fillColor: const Color(0xFFF3F3F5),
      filled: true,
    ),
  );

  // 다크 모드 테마도 여기에 정의할 수 있습니다.
  // static final ThemeData darkTheme = ThemeData(...);
}