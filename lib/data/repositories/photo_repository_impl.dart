import '../../core/constants/api_constants.dart';
import '../../domain/repositories/photo_repository.dart';
import '../datasources/pexels_api_service.dart';
import '../models/photo_model.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PexelsApiService _apiService;
  
  PhotoRepositoryImpl(this._apiService);
  
  @override
  Future<List<PhotoModel>> getCuratedPhotos({int page = 1}) async {
    return await _apiService.getCuratedPhotos(
      page: page,
      perPage: ApiConstants.perPage,
    );
  }
  
  @override
  Future<List<PhotoModel>> searchPhotos({required String query, int page = 1}) async {
    return await _apiService.searchPhotos(
      query: query,
      page: page,
      perPage: ApiConstants.perPage,
    );
  }
}
