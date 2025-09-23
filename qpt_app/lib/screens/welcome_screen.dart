// lib/screens/welcome_screen.dart

import 'dart:ui'; // BackdropFilter를 위해 필요
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 배경 그라데이션
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // 2. 메인 콘텐츠
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),
                  _buildLogoAndBrand(),
                  const SizedBox(height: 48),
                  _buildFeatureList(),
                  const SizedBox(height: 48),
                  _buildCtaButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoAndBrand() {
    return Column(
      children: [
        Transform.rotate(
          angle: -0.2, // 12도 정도 회전
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.orange, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.show_chart, color: Colors.white, size: 40),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Q-PT', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
        const Text('AI. DATA. PERFORMANCE.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        const Text(
          'Your quiet personal trainer, always by your side',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeatureCard(Icons.track_changes, Colors.blue, 'InBody Integration', 'OCR-powered body composition tracking'),
        const SizedBox(height: 16),
        _buildFeatureCard(Icons.bar_chart, Colors.orange, 'Smart Diet Tracking', 'AI-powered food analysis from photos'),
        const SizedBox(height: 16),
        _buildFeatureCard(Icons.fitness_center, Colors.green, 'Workout Planner', 'Personalized exercise routines'),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, Color color, String title, String subtitle) {
    // ClipRRect로 감싸서 블러 효과가 카드를 벗어나지 않도록 함
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        // 블러 효과
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6), // 반투명 배경
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCtaButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 커스텀 그라데이션 버튼
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.green],
                  ),
                ),
                child: const SizedBox(height: 56), // 버튼 높이
              ),
              TextButton(
                onPressed: onGetStarted,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                  fixedSize: const Size.fromHeight(56),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Center(child: Text('Get Started')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Perfect for fitness beginners seeking affordable guidance',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        )
      ],
    );
  }
}