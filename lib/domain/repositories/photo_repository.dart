import '../../data/models/photo_model.dart';

abstract class PhotoRepository {
  Future<List<PhotoModel>> getCuratedPhotos({int page = 1});
  Future<List<PhotoModel>> searchPhotos({required String query, int page = 1});
}
