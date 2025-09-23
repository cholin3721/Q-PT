// lib/widgets/app_input_otp.dart

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../theme/colors.dart';

class AppInputOTP extends StatelessWidget {
  const AppInputOTP({super.key});

  @override
  Widget build(BuildContext context) {
    // pinput의 기본 테마 (입력 전)
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineBorder),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    // pinput의 포커스된 테마 (입력 중)
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    return Pinput(
      length: 6, // 6자리 OTP
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      onCompleted: (pin) => print('Entered OTP: $pin'),
    );
  }
}