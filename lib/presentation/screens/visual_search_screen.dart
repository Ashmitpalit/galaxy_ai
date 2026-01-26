import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/models/photo_model.dart';
import '../../domain/repositories/photo_repository.dart';
import '../providers/photo_providers.dart';
import '../widgets/pin_card.dart';
import '../widgets/pin_shimmer.dart';

// State to hold search results and detected labels
class VisualSearchState {
  final List<PhotoModel> photos;
  final bool isLoading;
  final String currentQuery;
  final List<String> detectedLabels;
  final String? error;

  VisualSearchState({
    required this.photos,
    this.isLoading = true,
    this.currentQuery = '',
    this.detectedLabels = const [],
    this.error,
  });

  VisualSearchState copyWith({
    List<PhotoModel>? photos,
    bool? isLoading,
    String? currentQuery,
    List<String>? detectedLabels,
    String? error,
  }) {
    return VisualSearchState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      currentQuery: currentQuery ?? this.currentQuery,
      detectedLabels: detectedLabels ?? this.detectedLabels,
      error: error ?? this.error,
    );
  }
}

// Notifier to handle ML Kit Logic + API Call
class VisualSearchNotifier extends StateNotifier<VisualSearchState> {
  final PhotoRepository _repository;

  VisualSearchNotifier(this._repository) : super(VisualSearchState(photos: []));

  Future<void> analyzeAndSearch(File imageFile) async {
    try {
      if (!mounted) return;
      state = state.copyWith(isLoading: true, error: null);

      // 1. Prepare Input Image
      final inputImage = InputImage.fromFile(imageFile);

      // 2. Initialize Labeler
      final imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));

      // 3. Process Image
      final labels = await imageLabeler.processImage(inputImage);
      
      String query = 'aesthetic'; // Fallback
      List<String> detectedLabels = [];
      
      if (labels.isNotEmpty) {
        // Collect top labels
        detectedLabels = labels.map((l) => l.label).take(5).toList();
        
        // Get top label for initial search
        query = labels.first.label;
        debugPrint('Detected Labels: $detectedLabels');
      } else {
         debugPrint('No labels detected, using fallback.');
      }

      imageLabeler.close(); // Cleanup

      if (!mounted) return;

      // 4. Search Pexels
      await search(query, updateLabels: false);
      
      if (mounted) {
        state = state.copyWith(
          detectedLabels: detectedLabels,
        );
      }

    } catch (e) {
      debugPrint('Visual Search Error: $e');
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
          currentQuery: 'Visual matches',
        );
      }
      // Try fallback search 
      try {
         final photos = await _repository.searchPhotos(query: 'visual', page: 1);
         if (mounted) {
           state = state.copyWith(photos: photos);
         }
      } catch (_) {}
    }
  }

  Future<void> search(String query, {bool updateLabels = true}) async {
    try {
      if (!mounted) return;
      state = state.copyWith(isLoading: true, currentQuery: query);
      final photos = await _repository.searchPhotos(query: query, page: 1);
      if (mounted) {
        state = state.copyWith(
          photos: photos,
          isLoading: false,
        );
      }
    } catch (e) {
       if (mounted) {
         state = state.copyWith(isLoading: false, error: e.toString());
       }
    }
  }
}

final visualSearchProvider = StateNotifierProvider.autoDispose.family<VisualSearchNotifier, VisualSearchState, String>((ref, path) {
  final repository = ref.read(photoRepositoryProvider);
  final notifier = VisualSearchNotifier(repository);
  notifier.analyzeAndSearch(File(path));
  return notifier;
});

class VisualSearchScreen extends ConsumerStatefulWidget {
  final XFile imageFile;

  const VisualSearchScreen({
    super.key,
    required this.imageFile,
  });

  @override
  ConsumerState<VisualSearchScreen> createState() => _VisualSearchScreenState();
}

class _VisualSearchScreenState extends ConsumerState<VisualSearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(visualSearchProvider(widget.imageFile.path));
    
    // Sync controller with state if not editing
    if (searchState.currentQuery.isNotEmpty && _searchController.text != searchState.currentQuery) {
       // Only update if the user isn't actively typing? 
       // For now, let's just sync it when it changes from the AI
       _searchController.text = searchState.currentQuery;
       _searchController.selection = TextSelection.collapsed(offset: searchState.currentQuery.length);
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            backgroundColor: Colors.black,
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(widget.imageFile.path),
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search...',
                              hintStyle: TextStyle(color: Colors.white70),
                              suffixIcon: Icon(Icons.edit, color: Colors.white70),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                ref.read(visualSearchProvider(widget.imageFile.path).notifier).search(value);
                              }
                            },
                          ),
                          if (searchState.detectedLabels.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: searchState.detectedLabels.map((label) {
                                  final isSelected = label.toLowerCase() == searchState.currentQuery.toLowerCase();
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      label: Text(label),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        ref.read(visualSearchProvider(widget.imageFile.path).notifier).search(label);
                                      },
                                      backgroundColor: Colors.white24,
                                      selectedColor: Colors.white,
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.black : Colors.white,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          const SizedBox(height: 8),
                          const Text(
                            'Demo Mode: AI accuracy may vary.',
                            style: TextStyle(color: Colors.white54, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Visual matches',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (searchState.isLoading)
             SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childCount: 6,
                itemBuilder: (context, index) => const PinShimmer(height: 200),
              ),
            )
          else if (searchState.error != null)
             SliverToBoxAdapter(
              child: Center(
                 child: Padding(
                   padding: const EdgeInsets.all(32.0),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                       const SizedBox(height: 16),
                       Text(
                         'Could not analyze image.',
                         style: Theme.of(context).textTheme.titleMedium,
                         textAlign: TextAlign.center,
                       ),
                       const SizedBox(height: 8),
                       Text(
                         searchState.error ?? 'Unknown error',
                         style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                         textAlign: TextAlign.center,
                       ),
                       const SizedBox(height: 24),
                       ElevatedButton.icon(
                         onPressed: () {
                           // Retry analysis
                           ref.read(visualSearchProvider(widget.imageFile.path).notifier).analyzeAndSearch(File(widget.imageFile.path));
                         },
                         icon: const Icon(Icons.refresh),
                         label: const Text('Retry'),
                       ),
                     ],
                   ),
                 ),
              ),
            )
          else
             SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childCount: searchState.photos.length,
                itemBuilder: (context, index) {
                  return PinCard(photo: searchState.photos[index]);
                },
              ),
            ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
