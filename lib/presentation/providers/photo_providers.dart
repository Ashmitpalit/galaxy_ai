import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pexels_api_service.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../data/models/photo_model.dart';
import 'user_preferences_providers.dart';

// API Service Provider
final pexelsApiServiceProvider = Provider<PexelsApiService>((ref) {
  return PexelsApiService();
});

// Repository Provider
final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepositoryImpl(ref.watch(pexelsApiServiceProvider));
});

// Category State
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

// Home Feed State Notifier
class HomeFeedNotifier extends StateNotifier<AsyncValue<List<PhotoModel>>> {
  final PhotoRepository _repository;
  final String _category;
  final List<String> _topSearchTerms;
  int _currentPage = 1;
  List<PhotoModel> _allPhotos = [];
  bool _hasMore = true;
  
  HomeFeedNotifier(
    this._repository,
    this._category,
    this._topSearchTerms,
  ) : super(const AsyncValue.loading()) {
    loadInitialPhotos();
  }
  
  Future<void> loadInitialPhotos() async {
    if (!mounted) return; // Prevent updates after dispose
    
    state = const AsyncValue.loading();
    try {
      final List<PhotoModel> photos;
      
      if (_category == 'All') {
        // Personalized feed based on search history
        photos = await _fetchPersonalizedPhotos(page: 1);
      } else {
        // Category-specific feed
        photos = await _repository.searchPhotos(query: _category, page: 1);
      }
      
      if (!mounted) return; // Check again after async operation
      
      _allPhotos = photos;
      _currentPage = 1;
      _hasMore = photos.isNotEmpty;
      state = AsyncValue.data(_allPhotos);
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<List<PhotoModel>> _fetchPersonalizedPhotos({required int page}) async {
    // Temporarily disabled personalization for debugging
    // TODO: Re-enable after fixing the loading issue
    return await _repository.getCuratedPhotos(page: page);
    
    /* ORIGINAL PERSONALIZATION CODE - COMMENTED OUT
    // If user has search history, create personalized mix
    if (_topSearchTerms.isNotEmpty) {
      final List<PhotoModel> mixedPhotos = [];
      
      // Fetch photos from top 3 search terms
      final termsToUse = _topSearchTerms.take(3).toList();
      
      for (final term in termsToUse) {
        try {
          // Fetch a few photos from each term
          final photos = await _repository.searchPhotos(
            query: term,
            page: page,
          );
          
          // Take a portion from each category
          final portion = (photos.length / termsToUse.length).ceil();
          mixedPhotos.addAll(photos.take(portion));
        } catch (e) {
          // Continue with other terms if one fails
          continue;
        }
      }
      
      // Shuffle to mix the categories
      mixedPhotos.shuffle();
      
      // If we got personalized content, return it
      if (mixedPhotos.isNotEmpty) {
        return mixedPhotos;
      }
    }
    
    // Fallback to curated photos for new users or if personalization fails
    return await _repository.getCuratedPhotos(page: page);
    */
  }
  
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading || !mounted) return;
    
    try {
      _currentPage++;
      final List<PhotoModel> newPhotos;
      
      if (_category == 'All') {
        newPhotos = await _fetchPersonalizedPhotos(page: _currentPage);
      } else {
        newPhotos = await _repository.searchPhotos(
          query: _category,
          page: _currentPage,
        );
      }
      
      if (!mounted) return; // Check after async operation
      
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
  
  Future<void> refresh() async {
    await loadInitialPhotos();
  }
}

final homeFeedProvider = StateNotifierProvider.autoDispose<HomeFeedNotifier, AsyncValue<List<PhotoModel>>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  
  // Get top search terms for personalization
  final searchHistoryNotifier = ref.watch(searchHistoryProvider.notifier);
  // Watch the search history state to trigger rebuild when it changes
  ref.watch(searchHistoryProvider);
  final topSearchTerms = searchHistoryNotifier.getTopSearches(5);
  
  return HomeFeedNotifier(
    ref.watch(photoRepositoryProvider),
    category,
    topSearchTerms,
  );
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
