// lib/screens/inbody_setup_screen.dart (6 Fields Review Version)

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

  // ✅ 1. 데이터 항목 추가: BMI와 체지방률 컨트롤러 추가
  final Map<String, TextEditingController> _reviewControllers = {
    'height': TextEditingController(),
    'weight': TextEditingController(),
    'muscleMass': TextEditingController(),
    'fatMass': TextEditingController(),
    'bmi': TextEditingController(),
    'bodyFatPercentage': TextEditingController(),
  };

  void _handleImageUpload() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2));

    // ✅ 2. 데이터 처리 업데이트: Mock 데이터에 BMI와 체지방률 추가
    final mockOcrData = {
      'height': 175.0,
      'weight': 70.5,
      'muscleMass': 32.1,
      'fatMass': 12.8,
      'bmi': 23.0,
      'bodyFatPercentage': 18.2,
    };

    _reviewControllers['height']?.text = mockOcrData['height'].toString();
    _reviewControllers['weight']?.text = mockOcrData['weight'].toString();
    _reviewControllers['muscleMass']?.text = mockOcrData['muscleMass'].toString();
    _reviewControllers['fatMass']?.text = mockOcrData['fatMass'].toString();
    _reviewControllers['bmi']?.text = mockOcrData['bmi'].toString();
    _reviewControllers['bodyFatPercentage']?.text = mockOcrData['bodyFatPercentage'].toString();

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

  Future<bool> _onWillPop() async {
    if (_pageController.page?.round() != 0) {
      _goToPreviousStep();
      return false;
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('InBody Setup'),
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        leading: _pageController.positions.isNotEmpty && _pageController.page?.round() != 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goToPreviousStep,
        )
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildUploadStep(),
          _buildReviewStep(),
          _buildGoalsStep(),
        ],
      ),
    );
  }

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
    return _buildStepWrapper(
      child: AppCard(
        header: AppCardHeader(
          title: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.track_changes, color: AppColors.primary),
                SizedBox(width: 8),
                Text('InBody Setup'),
              ],
            ),
          ),
          description: const Center(
              child: Text(
                'Upload your InBody result sheet to get started',
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
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
                  child: Column(
                    children: [
                      const Icon(Icons.upload_file, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('Take a photo or upload your sheet'),
                      const SizedBox(height: 16),
                      AppButton(
                        onPressed: _handleImageUpload,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 16),
                            SizedBox(width: 8),
                            Text('Upload Photo'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: AppButton(
                  onPressed: _handleImageUpload,
                  variant: AppButtonVariant.outline,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, size: 16),
                      SizedBox(width: 8),
                      Text('Enter Manually'),
                    ],
                  ),
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
          title: const Text('Review Your Data'),
          description: const Text('Please verify the extracted information.'),
        ),
        content: AppCardContent(
          // ✅ 3. UI 레이아웃 변경: 6개 필드를 표시하도록 수정
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
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const AppLabel('BMI'), AppInput(controller: _reviewControllers['bmi'])])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const AppLabel('Body Fat %'), AppInput(controller: _reviewControllers['bodyFatPercentage'])])),
              ]),
              const SizedBox(height: 24),
              AppButton(onPressed: _handleProceedToGoals, child: const Text('Continue to Goals')),
              const SizedBox(height: 16),
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
          title: const Row(children: [
            Icon(Icons.track_changes, color: Colors.green),
            SizedBox(width: 8),
            Text('Set Your Goals'),
          ]),
          description: const Text('We\'ve suggested some goals based on your data.'),
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
              AppButton(
                onPressed: widget.onComplete,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 16),
                    SizedBox(width: 8),
                    Text('Complete Setup'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}