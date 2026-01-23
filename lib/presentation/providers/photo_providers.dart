import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pexels_api_service.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../data/models/photo_model.dart';

// API Service Provider
final pexelsApiServiceProvider = Provider<PexelsApiService>((ref) {
  return PexelsApiService();
});

// Repository Provider
final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepositoryImpl(ref.watch(pexelsApiServiceProvider));
});

// Curated Photos State Notifier
class CuratedPhotosNotifier extends StateNotifier<AsyncValue<List<PhotoModel>>> {
  final PhotoRepository _repository;
  int _currentPage = 1;
  List<PhotoModel> _allPhotos = [];
  bool _hasMore = true;
  
  CuratedPhotosNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadInitialPhotos();
  }
  
  Future<void> loadInitialPhotos() async {
    state = const AsyncValue.loading();
    try {
      final photos = await _repository.getCuratedPhotos(page: 1);
      _allPhotos = photos;
      _currentPage = 1;
      _hasMore = photos.isNotEmpty;
      state = AsyncValue.data(_allPhotos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    
    try {
      _currentPage++;
      final newPhotos = await _repository.getCuratedPhotos(page: _currentPage);
      
      if (newPhotos.isEmpty) {
        _hasMore = false;
      } else {
        _allPhotos = [..._allPhotos, ...newPhotos];
        state = AsyncValue.data(_allPhotos);
      }
    } catch (error) {
      _currentPage--;
      // Don't update state on pagination error, just silently fail
    }
  }
  
  Future<void> refresh() async {
    await loadInitialPhotos();
  }
}

final curatedPhotosProvider = StateNotifierProvider<CuratedPhotosNotifier, AsyncValue<List<PhotoModel>>>((ref) {
  return CuratedPhotosNotifier(ref.watch(photoRepositoryProvider));
});

// Search Photos State Notifier
class SearchPhotosNotifier extends StateNotifier<AsyncValue<List<PhotoModel>>> {
  final PhotoRepository _repository;
  String _currentQuery = '';
  int _currentPage = 1;
  List<PhotoModel> _allPhotos = [];
  bool _hasMore = true;
  
  SearchPhotosNotifier(this._repository) : super(const AsyncValue.data([]));
  
  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    
    _currentQuery = query;
    state = const AsyncValue.loading();
    
    try {
      final photos = await _repository.searchPhotos(query: query, page: 1);
      _allPhotos = photos;
      _currentPage = 1;
      _hasMore = photos.isNotEmpty;
      state = AsyncValue.data(_allPhotos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading || _currentQuery.isEmpty) return;
    
    try {
      _currentPage++;
      final newPhotos = await _repository.searchPhotos(
        query: _currentQuery,
        page: _currentPage,
      );
      
      if (newPhotos.isEmpty) {
        _hasMore = false;
      } else {
        _allPhotos = [..._allPhotos, ...newPhotos];
        state = AsyncValue.data(_allPhotos);
      }
    } catch (error) {
      _currentPage--;
    }
  }
}

final searchPhotosProvider = StateNotifierProvider<SearchPhotosNotifier, AsyncValue<List<PhotoModel>>>((ref) {
  return SearchPhotosNotifier(ref.watch(photoRepositoryProvider));
});
