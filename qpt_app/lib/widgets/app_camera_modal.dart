// lib/widgets/app_camera_modal.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'app_button.dart';
import '../theme/colors.dart';

class AppCameraModal extends StatefulWidget {
  final String title;
  final Function(File) onImageSelected;

  const AppCameraModal({
    super.key,
    this.title = "음식 사진 촬영",
    required this.onImageSelected,
  });

  @override
  State<AppCameraModal> createState() => _AppCameraModalState();
}

class _AppCameraModalState extends State<AppCameraModal> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _handleConfirm() {
    if (_selectedImage != null) {
      widget.onImageSelected(_selectedImage!);
      Navigator.of(context).pop(); // 모달 닫기
    }
  }

  void _handleRetake() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 24),
          
          // 이미지가 선택되었는지에 따라 다른 UI 표시
          if (_selectedImage == null)
            _buildSelectionUI()
          else
            _buildPreviewUI(),
        ],
      ),
    );
  }

  Widget _buildSelectionUI() {
    return DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(12),
        color: AppColors.outlineBorder,
        dashPattern: const [6, 6],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey),
            const Text('음식 사진을 촬영하거나 갤러리에서 선택하세요'),
            const SizedBox(height: 16),
            AppButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.camera_alt), SizedBox(width: 8), Text('카메라로 촬영')]),
            ),
            const SizedBox(height: 8),
            AppButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              variant: AppButtonVariant.outline,
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.photo_library), SizedBox(width: 8), Text('갤러리에서 선택')]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewUI() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            height: 256,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(onPressed: _handleRetake, variant: AppButtonVariant.outline, child: const Text('다시 선택')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppButton(onPressed: _handleConfirm, child: const Text('사용하기')),
            ),
          ],
        ),
      ],
    );
  }
}