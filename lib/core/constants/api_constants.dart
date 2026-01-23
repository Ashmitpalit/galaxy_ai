import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Pexels API
  static String get pexelsApiKey => dotenv.env['PEXELS_API_KEY'] ?? '';
  static const String pexelsBaseUrl = 'https://api.pexels.com/v1';
  
  // Endpoints
  static const String curatedPhotos = '/curated';
  static const String searchPhotos = '/search';
  
  // Pagination
  static const int perPage = 20;
}
