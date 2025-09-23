// lib/screens/auth_screen.dart (최종 수정본)

import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_input.dart';
import '../widgets/app_label.dart';

enum AuthStep { login, nickname }

class AuthScreen extends StatefulWidget {
  // 1. VoidCallback 대신, Map 데이터를 받는 함수 타입으로 변경
  final Function(Map<String, dynamic>) onAuthSuccess;
  final VoidCallback onBack; // 1. onBack 콜백을 받을 변수 추가

  // 2. 생성자에서 onBack을 필수로 받도록 수정
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
    print('Logging in with $provider');
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _step = AuthStep.nickname;
    });
  }

  void _handleNicknameCheck() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) return;

    setState(() { _isCheckingNickname = true; });
    await Future.delayed(const Duration(milliseconds: 500));

    final available = !["admin", "test", "user"].contains(nickname.toLowerCase());
    setState(() {
      _isNicknameAvailable = available;
      _isCheckingNickname = false;
    });
  }

  void _handleCompleteSetup() {
    if (_isNicknameAvailable != true) return;
    
    // 2. Mock 유저 데이터를 만들어서 onAuthSuccess 콜백에 담아 전달
    final userData = {
      'id': 1,
      'nickname': _nicknameController.text,
      'email': 'user@example.com',
      'provider': 'google',
    };
    widget.onAuthSuccess(userData);
  }
  
  // ... (initState, dispose, build 메소드는 이전과 동일) ...
  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(() {
      if (_isNicknameAvailable != null) {
        setState(() {
          _isNicknameAvailable = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  // lib/screens/auth_screen.dart

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
                  // 1. Center의 자식을 Column으로 감쌉니다.
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Column이 내용물만큼만 크기를 갖도록 함
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: _step == AuthStep.login ? _buildLoginStep() : _buildNicknameStep(),
                        ),
                      ),
                      // 2. 카드 아래에 원하는 만큼의 여백을 추가합니다.
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
  
  // ... (_buildLoginStep, _buildNicknameStep 메소드는 이전과 동일) ...
  Widget _buildLoginStep() {
    return AppCard(
      // 3. CardHeader 부분을 수정하여 뒤로가기 버튼을 추가합니다.
      header: AppCardHeader(
        title: Stack(
          alignment: Alignment.center,
          children: [
            // 제목은 가운데에 위치
            const Text('Welcome to Q-PT'),
            // 뒤로가기 버튼은 왼쪽에 위치
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                // 4. 버튼을 누르면 전달받은 onBack 함수를 호출
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
            const SizedBox(height: 35), // <-- 이 줄을 추가해서 카드 하단 여백 생성
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