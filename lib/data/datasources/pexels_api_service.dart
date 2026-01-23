import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/photo_model.dart';

class PexelsApiService {
  final Dio _dio;
  
  PexelsApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.pexelsBaseUrl,
            headers: {
              'Authorization': ApiConstants.pexelsApiKey,
            },
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
  
  Future<List<PhotoModel>> getCuratedPhotos({int page = 1, int perPage = 20}) async {
    try {
      final response = await _dio.get(
        ApiConstants.curatedPhotos,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      
      final List<dynamic> photos = response.data['photos'] as List<dynamic>;
      return photos.map((json) => PhotoModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<PhotoModel>> searchPhotos({
    required String query,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchPhotos,
        queryParameters: {
          'query': query,
          'page': page,
          'per_page': perPage,
        },
      );
      
      final List<dynamic> photos = response.data['photos'] as List<dynamic>;
      return photos.map((json) => PhotoModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error. Please try again.';
    }
  }
}
