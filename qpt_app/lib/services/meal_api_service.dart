import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class MealApiService {
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  // 음식 사진 촬영
  Future<File?> pickFoodImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      throw Exception('사진 촬영 실패: ${e.toString()}');
    }
  }

  // 갤러리에서 음식 사진 선택
  Future<File?> pickFoodImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      throw Exception('사진 선택 실패: ${e.toString()}');
    }
  }

  // 음식 사진 AI 분석
  Future<Map<String, dynamic>> analyzeFoodImage(File imageFile) async {
    return await _apiService.analyzeFoodImage(imageFile);
  }

  // 식단 기록
  Future<Map<String, dynamic>> createMeal({
    required String mealDate,
    required int mealType,
    String? imageUrl,
    required List<Map<String, dynamic>> foods,
  }) async {
    return await _apiService.createMeal({
      'mealDate': mealDate,
      'mealType': mealType,
      'imageUrl': imageUrl,
      'foods': foods,
    });
  }

  // 일별 식단 조회
  Future<Map<String, dynamic>> getMeals(String date) async {
    return await _apiService.getMeals(date);
  }
}
