import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';  // Android 에뮬레이터용
    } else {
      return 'http://localhost:3000/api'; // iOS 시뮬레이터/웹용
    }
  }
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // 요청 인터셉터 - JWT 토큰 자동 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getStoredToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // 토큰 만료 시 로그아웃 처리
          _clearStoredToken();
        }
        handler.next(error);
      },
    ));
  }

  // 토큰 저장
  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // 토큰 조회
  Future<String?> _getStoredToken() async {
    // 테스트용 고정 토큰 반환
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTczNzU0NzI1N30.test';
  }

  // 토큰 삭제
  Future<void> _clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // 인증 관련 API
  Future<Map<String, dynamic>> socialLogin(String provider, String accessToken) async {
    try {
      final response = await _dio.post('/auth/login/$provider', data: {
        'accessToken': accessToken,
      });
      
      if (response.data['jwt'] != null) {
        await _storeToken(response.data['jwt']);
      }
      
      return response.data;
    } catch (e) {
      throw Exception('로그인 실패: ${e.toString()}');
    }
  }

  // 사용자 관련 API
  Future<bool> checkNickname(String nickname) async {
    try {
      final response = await _dio.get('/users/nickname/check', queryParameters: {
        'nickname': nickname,
      });
      return response.data['isAvailable'];
    } catch (e) {
      throw Exception('닉네임 확인 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> setNickname(String nickname) async {
    try {
      final response = await _dio.put('/users/me/nickname', data: {
        'nickname': nickname,
      });
      return response.data;
    } catch (e) {
      throw Exception('닉네임 설정 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getMyInfo() async {
    try {
      final response = await _dio.get('/users/me');
      return response.data;
    } catch (e) {
      throw Exception('사용자 정보 조회 실패: ${e.toString()}');
    }
  }

  // 인바디 관련 API
  Future<Map<String, dynamic>> analyzeInBodyImage(File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });
      
      final response = await _dio.post('/inbody/ocr', data: formData);
      return response.data;
    } catch (e) {
      throw Exception('인바디 분석 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> registerInBody(Map<String, dynamic> inbodyData) async {
    try {
      final response = await _dio.post('/inbody', data: inbodyData);
      return response.data;
    } catch (e) {
      throw Exception('인바디 등록 실패: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getInBodyHistory() async {
    try {
      final response = await _dio.get('/inbody');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('인바디 이력 조회 실패: ${e.toString()}');
    }
  }

  // 목표 관련 API
  Future<Map<String, dynamic>> setGoal(Map<String, dynamic> goalData) async {
    try {
      final response = await _dio.post('/goals', data: goalData);
      return response.data;
    } catch (e) {
      throw Exception('목표 설정 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getActiveGoal() async {
    try {
      final response = await _dio.get('/goals/active');
      return response.data;
    } catch (e) {
      throw Exception('목표 조회 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> applyAINutrition(int feedbackId) async {
    try {
      final response = await _dio.post('/goals/apply-nutrition', data: {
        'feedbackId': feedbackId,
      });
      return response.data;
    } catch (e) {
      throw Exception('AI 영양소 적용 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateNutritionGoal({
    int? targetCalories,
    double? targetProtein,
    double? targetCarbs,
    double? targetFat,
  }) async {
    try {
      final response = await _dio.put('/goals/nutrition', data: {
        if (targetCalories != null) 'targetCalories': targetCalories,
        if (targetProtein != null) 'targetProtein': targetProtein,
        if (targetCarbs != null) 'targetCarbs': targetCarbs,
        if (targetFat != null) 'targetFat': targetFat,
      });
      return response.data;
    } catch (e) {
      throw Exception('영양소 목표 수정 실패: ${e.toString()}');
    }
  }

  // 식단 관련 API
  Future<Map<String, dynamic>> analyzeFoodImage(File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });
      
      final response = await _dio.post('/meals/image-analysis', data: formData);
      return response.data; // {recommended, candidates, calories, recognizedLabels}
    } catch (e) {
      throw Exception('음식 분석 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> createMeal(Map<String, dynamic> mealData) async {
    try {
      final response = await _dio.post('/meals', data: mealData);
      return response.data;
    } catch (e) {
      throw Exception('식단 기록 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getMeals(String date) async {
    try {
      final response = await _dio.get('/meals', queryParameters: {'date': date});
      return response.data;
    } catch (e) {
      throw Exception('식단 조회 실패: ${e.toString()}');
    }
  }

  // 운동 관련 API
  Future<List<Map<String, dynamic>>> getExercises({String? search}) async {
    try {
      final response = await _dio.get('/workouts/exercises', queryParameters: {
        if (search != null) 'search': search,
      });
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('운동 목록 조회 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> addExercise(Map<String, dynamic> exerciseData) async {
    try {
      final response = await _dio.post('/workouts/exercises', data: exerciseData);
      return response.data;
    } catch (e) {
      throw Exception('운동 등록 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> createWorkoutPlan(Map<String, dynamic> planData) async {
    try {
      final response = await _dio.post('/workouts/workout-plans', data: planData);
      return response.data;
    } catch (e) {
      throw Exception('운동 계획 생성 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getWorkoutPlan(String date) async {
    try {
      final response = await _dio.get('/workouts/workout-plans', queryParameters: {'date': date});
      return response.data;
    } catch (e) {
      // 운동 계획이 없으면 빈 데이터 반환
      return {
        'workoutPlanId': null,
        'status': 'none',
        'description': '',
        'sets': []
      };
    }
  }

  // AI 피드백 관련 API
  Future<Map<String, dynamic>> requestAIFeedback(String period) async {
    try {
      final response = await _dio.post('/ai/feedback', data: {'period': period});
      return response.data;
    } catch (e) {
      throw Exception('AI 피드백 요청 실패: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getAIFeedbacks() async {
    try {
      final response = await _dio.get('/ai/feedback');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('AI 피드백 조회 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> applyAIWorkout(int feedbackId, List<String> dates) async {
    try {
      final response = await _dio.post('/ai/apply-workout', data: {
        'feedbackId': feedbackId,
        'dates': dates,
      });
      return response.data;
    } catch (e) {
      throw Exception('AI 운동계획 적용 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> updateWorkoutSet(int setId, Map<String, dynamic> setData) async {
    try {
      final response = await _dio.put('/workouts/workout-plans/sets/$setId', data: setData);
      return response.data;
    } catch (e) {
      throw Exception('운동 세트 업데이트 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> addSetToPlan(int planId, Map<String, dynamic> setData) async {
    try {
      final response = await _dio.post('/workouts/workout-plans/$planId/sets', data: setData);
      return response.data;
    } catch (e) {
      throw Exception('세트 추가 실패: ${e.toString()}');
    }
  }

  // 루틴 관련 API
  Future<List<Map<String, dynamic>>> getRoutines() async {
    try {
      final response = await _dio.get('/routines');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('루틴 목록 조회 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getRoutineDetail(int routineId) async {
    try {
      final response = await _dio.get('/routines/$routineId');
      return response.data;
    } catch (e) {
      throw Exception('루틴 상세 조회 실패: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> createRoutine(Map<String, dynamic> routineData) async {
    try {
      final response = await _dio.post('/routines', data: routineData);
      return response.data;
    } catch (e) {
      throw Exception('루틴 생성 실패: ${e.toString()}');
    }
  }

  Future<void> deleteRoutine(int routineId) async {
    try {
      await _dio.delete('/routines/$routineId');
    } catch (e) {
      throw Exception('루틴 삭제 실패: ${e.toString()}');
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await _clearStoredToken();
  }
}
