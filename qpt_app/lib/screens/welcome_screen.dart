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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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
          angle: 0.2, // React 코드의 rotate-12와 유사하게 조정
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
        const SizedBox(height: 16),
        // ✅ 4번째 'AI Personal Trainer' 카드를 추가했습니다.
        _buildFeatureCard(Icons.psychology, Colors.purple, 'AI Personal Trainer', 'Intelligent feedback and recommendations'),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, Color color, String title, String subtitle) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
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
        // ✅ 버튼 스타일을 개선하여 텍스트가 잘 보이도록 수정했습니다.
        ElevatedButton(
          onPressed: onGetStarted,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            elevation: 5,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blue, Colors.green]),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: const Text(
                'Get Started',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
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