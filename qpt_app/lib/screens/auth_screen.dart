// lib/screens/auth_screen.dart (Bug Fixed Version)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_input.dart';
import '../widgets/app_label.dart';
import '../services/api_service.dart';

enum AuthStep { login, nickname }

class AuthScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onAuthSuccess;
  final VoidCallback onBack;

  const AuthScreen({
    super.key,
    required this.onAuthSuccess,
    required this.onBack,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthStep _step = AuthStep.login;
  final _nicknameController = TextEditingController();
  bool _isCheckingNickname = false;
  bool? _isNicknameAvailable;

  void _handleSocialLogin(String provider) async {
    try {
      // 테스트용 JWT 토큰 생성 (실제로는 서버에서 발급받아야 함)
      final mockJwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTczNzU0NzI1N30.test';
      
      // 토큰을 SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', mockJwt);
      
      final userData = {
        'id': 1,
        'nickname': '김철중',
        'email': 'cholin3721@example.com',
        'provider': provider,
      };
      widget.onAuthSuccess(userData);
    } catch (e) {
      // 에러가 발생해도 사용자 데이터는 전달
      final userData = {
        'id': 1,
        'nickname': '김철중',
        'email': 'cholin3721@example.com',
        'provider': provider,
      };
      widget.onAuthSuccess(userData);
    }
  }

  void _handleNicknameCheck() async {
    // 테스트용 프리패스 - 항상 사용 가능
    setState(() { _isCheckingNickname = true; });
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isNicknameAvailable = true;
        _isCheckingNickname = false;
      });
    }
  }

  void _handleCompleteSetup() async {
    // 테스트용 프리패스 - 김철중 사용자로 바로 로그인
    final userData = {
      'id': 1,
      'nickname': '김철중',
      'email': 'cholin3721@example.com',
      'provider': 'google',
    };
    widget.onAuthSuccess(userData);
  }

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(() {
      // ✅ 텍스트가 변경될 때마다 항상 setState를 호출하여 UI(특히 버튼 상태)를 갱신합니다.
      setState(() {
        // 추가로, 텍스트가 수정되면 이전 닉네임 검사 결과는 초기화합니다.
        if (_isNicknameAvailable != null) {
          _isNicknameAvailable = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.green.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _step == AuthStep.login ? _buildLoginStep() : _buildNicknameStep(),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginStep() {
    return AppCard(
      header: AppCardHeader(
        title: Stack(
          alignment: Alignment.center,
          children: [
            const Text('Welcome to Q-PT'),
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                onPressed: widget.onBack,
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.icon,
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
        description: const Center(child: Text('Sign in to start your fitness journey')),
      ),
      content: AppCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _handleSocialLogin('google'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black87),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('G', style: TextStyle(backgroundColor: Colors.red, color: Colors.white)),
                SizedBox(width: 8), Text('Continue with Google')
              ]),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _handleSocialLogin('kakao'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFE812), foregroundColor: Colors.black87),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('K', style: TextStyle(backgroundColor: Colors.black, color: Color(0xFFFFE812))),
                SizedBox(width: 8), Text('Continue with Kakao')
              ]),
            ),
            const SizedBox(height: 16),
            const Text(
              'By signing in, you agree to our Terms of Service and Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Widget _buildNicknameStep() {
    return AppCard(
      header: AppCardHeader(
        title: Row(children: [
          AppButton(
            onPressed: () => setState(() => _step = AuthStep.login),
            variant: AppButtonVariant.ghost, size: AppButtonSize.icon,
            child: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Text('Choose Your Nickname')),
        ]),
        description: const Padding(
          padding: EdgeInsets.only(left: 48.0),
          child: Text('This will be your display name in Q-PT'),
        ),
      ),
      content: AppCardContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppLabel('Nickname'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                        hintText: 'Enter your nickname',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12)
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  onPressed: _nicknameController.text.trim().isEmpty || _isCheckingNickname
                      ? null
                      : _handleNicknameCheck,
                  variant: AppButtonVariant.outline,
                  child: _isCheckingNickname ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Check'),
                ),
              ],
            ),
            if (_isNicknameAvailable == true)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('✓ Nickname is available', style: TextStyle(color: Colors.green)),
              ),
            if (_isNicknameAvailable == false)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('✗ Nickname is already taken', style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            AppButton(
              onPressed: _isNicknameAvailable == true ? _handleCompleteSetup : null,
              child: const Text('Complete Setup'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}