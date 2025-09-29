// lib/screens/inbody_setup_screen.dart (최종 수정본)

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import '../widgets/app_card.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../widgets/app_label.dart';
import '../widgets/app_textarea.dart';
import '../theme/colors.dart';

enum InBodyStep { upload, review, goals }

class InBodySetupScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onComplete;

  const InBodySetupScreen({
    super.key,
    required this.user,
    required this.onComplete,
  });

  @override
  State<InBodySetupScreen> createState() => _InBodySetupScreenState();
}

class _InBodySetupScreenState extends State<InBodySetupScreen> {
  final PageController _pageController = PageController();
  bool _isUploading = false;
  Map<String, dynamic>? _ocrData;

  final Map<String, TextEditingController> _reviewControllers = {
    'height': TextEditingController(),
    'weight': TextEditingController(),
    'muscleMass': TextEditingController(),
    'fatMass': TextEditingController(),
  };

  void _handleImageUpload() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2));

    final mockOcrData = { 'height': 175.0, 'weight': 70.5, 'muscleMass': 32.1, 'fatMass': 12.8 };

    _reviewControllers['height']?.text = mockOcrData['height'].toString();
    _reviewControllers['weight']?.text = mockOcrData['weight'].toString();
    _reviewControllers['muscleMass']?.text = mockOcrData['muscleMass'].toString();
    _reviewControllers['fatMass']?.text = mockOcrData['fatMass'].toString();

    setState(() {
      _ocrData = mockOcrData;
      _isUploading = false;
    });

    _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _goToPreviousStep() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _handleProceedToGoals() {
    _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  // 시스템 뒤로가기 버튼 처리를 위한 함수
  Future<bool> _onWillPop() async {
    // 현재 페이지가 첫 페이지가 아니라면
    if (_pageController.page?.round() != 0) {
      // 이전 페이지로 이동
      _goToPreviousStep();
      // 앱이 종료되는 것을 막음
      return false;
    }
    // 첫 페이지라면 시스템 기본 동작(화면 닫기)을 따름
    return true;
  }


  @override
  void dispose() {
    _pageController.dispose();
    _reviewControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope로 Scaffold를 감싸서 시스템 뒤로가기 제어
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildUploadStep(),
            _buildReviewStep(),
            _buildGoalsStep(),
          ],
        ),
      ),
    );
  }

  // 각 단계를 감싸는 공통 레이아웃 위젯
  Widget _buildStepWrapper({required Widget child}) {
    return Container(
      color: Colors.grey.shade100,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
      child: AppCard(
        header: const AppCardHeader(
          title: Center(child: Text('InBody Setup')),
          description: Center(
              child: Text(
                'Upload your InBody result sheet to get started.',
                textAlign: TextAlign.center,
              )),
        ),
        content: AppCardContent(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: _isUploading
              ? const SizedBox(
              height: 250,
              child: Center(child: CircularProgressIndicator()))
              : Column(
            children: [
              DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  radius: const Radius.circular(12),
                  color: AppColors.outlineBorder,
                  strokeWidth: 1,
                  dashPattern: const [6, 6],
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
                    child: Column(
                      children: [
                        const Icon(Icons.cloud_upload_outlined,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text(
                            'Take a photo or upload your sheet'),
                        const SizedBox(height: 16),
                        AppButton(
                            onPressed: _handleImageUpload,
                            child: const Text('Upload Photo')),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200, // 예시 너비
                child: AppButton(
                  onPressed: _handleImageUpload,
                  variant: AppButtonVariant.outline,
                  child: const Text('Enter Manually'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return _buildStepWrapper(
      child: AppCard(
        header: AppCardHeader(
          title: Row(children: [
            AppButton(onPressed: _goToPreviousStep, variant: AppButtonVariant.ghost, size: AppButtonSize.icon, child: const Icon(Icons.arrow_back)),
            const SizedBox(width: 8),
            const Expanded(child: Text('Review Your Data')),
          ]),
          description: const Padding(padding: EdgeInsets.only(left: 48.0), child: Text('Please verify the extracted information.')),
        ),
        content: AppCardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const AppLabel('Height (cm)'), AppInput(controller: _reviewControllers['height'])])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const AppLabel('Weight (kg)'), AppInput(controller: _reviewControllers['weight'])])),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const AppLabel('Muscle (kg)'), AppInput(controller: _reviewControllers['muscleMass'])])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const AppLabel('Fat (kg)'), AppInput(controller: _reviewControllers['fatMass'])])),
              ]),
              const SizedBox(height: 24),
              AppButton(onPressed: _handleProceedToGoals, child: const Text('Continue to Goals')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsStep() {
    return _buildStepWrapper(
      child: AppCard(
        header: AppCardHeader(
          title: Row(children: [
            AppButton(onPressed: _goToPreviousStep, variant: AppButtonVariant.ghost, size: AppButtonSize.icon, child: const Icon(Icons.arrow_back)),
            const SizedBox(width: 8),
            const Expanded(child: Text('Set Your Goals')),
          ]),
          description: const Padding(padding: EdgeInsets.only(left: 48.0), child: Text('We\'ve suggested some goals based on your data.')),
        ),
        content: AppCardContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLabel('Target Weight (kg)'),
              AppInput(hintText: 'e.g., 68.0'),
              const SizedBox(height: 16),
              const AppLabel('Additional Goals'),
              const AppTextarea(hintText: 'e.g., Improve endurance...', minLines: 2),
              const SizedBox(height: 24),
              AppButton(onPressed: widget.onComplete, child: const Text('Complete Setup')),
            ],
          ),
        ),
      ),
    );
  }
}