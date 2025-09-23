// lib/widgets/app_label.dart

import 'package:flutter/material.dart';

class AppLabel extends StatelessWidget {
  final String text;
  const AppLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500, // font-medium
      ),
    );
  }
}