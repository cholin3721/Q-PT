// lib/widgets/app_camera_modal.dart (Translated Version)

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
    this.title = "Upload Image", // "음식 사진 촬영" -> "Upload Image"
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
      Navigator.of(context).pop(); // Close modal
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 24),

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
            const SizedBox(height: 8),
            // "음식 사진을 촬영하거나..." -> "Take a photo or select..."
            const Text('Take a photo or select from your gallery'),
            const SizedBox(height: 16),
            AppButton(
              onPressed: () => _pickImage(ImageSource.camera),
              // "카메라로 촬영" -> "Take Photo"
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.camera_alt), SizedBox(width: 8), Text('Take Photo')]),
            ),
            const SizedBox(height: 8),
            AppButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              variant: AppButtonVariant.outline,
              // "갤러리에서 선택" -> "Choose from Gallery"
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.photo_library), SizedBox(width: 8), Text('Choose from Gallery')]),
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
              // "다시 선택" -> "Choose Again"
              child: AppButton(onPressed: _handleRetake, variant: AppButtonVariant.outline, child: const Text('Choose Again')),
            ),
            const SizedBox(width: 8),
            Expanded(
              // "사용하기" -> "Confirm"
              child: AppButton(onPressed: _handleConfirm, child: const Text('Confirm')),
            ),
          ],
        ),
      ],
    );
  }
}