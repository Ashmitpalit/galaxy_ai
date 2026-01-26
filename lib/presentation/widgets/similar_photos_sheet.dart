import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/models/photo_model.dart';
import '../providers/photo_providers.dart';
import 'masonry_grid.dart';

class SimilarPhotosSheet extends ConsumerStatefulWidget {
  final String query;
  final ScrollController scrollController;

  const SimilarPhotosSheet({
    super.key,
    required this.query,
    required this.scrollController,
  });

  @override
  ConsumerState<SimilarPhotosSheet> createState() => _SimilarPhotosSheetState();
}

class _SimilarPhotosSheetState extends ConsumerState<SimilarPhotosSheet> {
  List<PhotoModel> _photos = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (!_hasMore) return;

    try {
      final repository = ref.read(photoRepositoryProvider);
      // Construct a search query that focuses on visual similarity
      // We use the provided query (likely alt text or tags)
      final newPhotos = await repository.searchPhotos(
        query: widget.query,
        page: _page,
      );

      if (mounted) {
        setState(() {
          if (newPhotos.isEmpty) {
            _hasMore = false;
          } else {
            _photos.addAll(newPhotos);
            _page++;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Could not load similar ideas\n$_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _loadPhotos();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_photos.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_photos.isEmpty) {
      return const Center(
        child: Text('No similar ideas found'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'More like this',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: MasonryGrid(
            photos: _photos,
            isLoading: _isLoading,
            onLoadMore: () {
              if (!_isLoading) {
                _loadPhotos();
              }
            },
          ),
        ),
      ],
    );
  }
}
