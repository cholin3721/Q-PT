// lib/widgets/app_form.dart

import 'package:flutter/material.dart';
import 'app_button.dart';

class AppLoginForm extends StatefulWidget {
  const AppLoginForm({super.key});

  @override
  State<AppLoginForm> createState() => _AppLoginFormState();
}

class _AppLoginFormState extends State<AppLoginForm> {
  // 1. Form 위젯을 제어하기 위한 '리모컨' (GlobalKey) 생성
  final _formKey = GlobalKey<FormState>();

  // 2. 입력된 값을 저장할 변수
  String _email = '';
  String _password = '';

  void _submitForm() {
    // 3. '제출' 버튼을 눌렀을 때, Form의 유효성 검사를 실행
    final isValid = _formKey.currentState?.validate() ?? false;
    
    if (isValid) {
      // 4. 유효성 검사를 통과하면, Form의 값을 저장
      _formKey.currentState?.save();
      
      // 5. 저장된 값으로 실제 로그인 로직을 실행 (지금은 스낵바로 성공 메시지 표시)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Success! Email: $_email, Password: $_password'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Form 위젯이 모든 TextFormField들을 감쌉니다.
    return Form(
      key: _formKey, // 리모컨 연결
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- 이메일 입력창 ---
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            // 유효성 검사 로직
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null; // 유효하면 null 반환
            },
            // 값이 저장될 때 _email 변수에 할당
            onSaved: (value) {
              _email = value ?? '';
            },
          ),
          const SizedBox(height: 16),

          // --- 비밀번호 입력창 ---
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true, // 비밀번호 가리기
            // 유효성 검사 로직
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters long';
              }
              return null;
            },
            onSaved: (value) {
              _password = value ?? '';
            },
          ),
          const SizedBox(height: 24),

          // --- 제출 버튼 ---
          AppButton(
            onPressed: _submitForm, // 버튼을 누르면 _submitForm 함수 실행
            child: const Text('Log In'),
          )
        ],
      ),
    );
  }
}