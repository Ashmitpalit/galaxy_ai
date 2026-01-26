import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/models/photo_model.dart';

import '../providers/photo_providers.dart';
import '../providers/user_preferences_providers.dart';
import '../widgets/masonry_grid.dart';
import '../widgets/search/trending_carousel.dart';
import '../widgets/search/ideas_for_you.dart';
import '../widgets/search/popular_sliver_grid.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    // Don't auto-focus on landing to show the beautiful UI
    // _focusNode.requestFocus(); 
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      ref.read(searchPhotosProvider.notifier).search(query.trim());
      // Record search history for Home Tabs
      ref.read(searchHistoryProvider.notifier).addSearch(query.trim());
    }
  }

  Future<void> _handleCameraClick() async {
    // Check permissions
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // We haven't asked for permission yet or the permission has been denied before but not permanently.
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
      return;
    }

    if (status.isGranted) {
      try {
        final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          if (mounted) {
            context.push('/visual-search', extra: photo);
          }
        }
      } catch (e) {
        debugPrint('Error picking image: $e');
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission'),
        content: const Text('This app needs camera access to search by image. Please enable it in settings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            }, 
            child: const Text('Settings')
          ),
        ],
      ),
    );
  }


  
  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchPhotosProvider);
    final searchHistory = ref.watch(searchHistoryProvider.notifier);
    final recentSearches = searchHistory.getRecentSearches(10);
    
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: UIConstants.searchBarHeight,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(UIConstants.searchBarBorderRadius),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onSubmitted: _performSearch,
            decoration: InputDecoration(
              hintText: 'Search for ideas',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        // Clear search results - go back to empty state
                        ref.read(searchPhotosProvider.notifier).search('');
                        setState(() {
                          _isSearching = false;
                        });
                        _focusNode.unfocus();
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                    onPressed: _handleCameraClick,
                  ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (value) {
               // Optional: Live search logic
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          // Content Layer
          _isSearching 
            ? _buildSearchResults(searchState) 
            : _buildLandingPage(),
            
          // Search History Overlay (only when strictly focused and not fully searching yet)
          // or we can treat focusing as "searching" state but with empty query.
          // For Pinterest Style: clicking search bar usually shows history immediately masking the landing page.
          if (_focusNode.hasFocus && _searchController.text.isEmpty && recentSearches.isNotEmpty)
            Positioned.fill(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildRecentSearches(recentSearches, searchHistory),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLandingPage() {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: TrendingCarousel()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        const SliverToBoxAdapter(child: IdeasForYou()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Popular on Pinterest',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const PopularSliverGrid(),
      ],
    );
  }

  Widget _buildSearchResults(AsyncValue<List<PhotoModel>> searchState) {
    return searchState.when(
      data: (photos) {
        if (photos.isEmpty) {
           return _buildScrollableCenter([
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ]);
        }
        return MasonryGrid(
          photos: photos, 
          onLoadMore: () {
            ref.read(searchPhotosProvider.notifier).loadMore();
          },
        );
      },
      loading: () => MasonryGrid(photos: const [], isLoading: true),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildRecentSearches(List<String> searches, dynamic historyNotifier) {
     return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () async {
                    await historyNotifier.clearAll();
                    setState(() {});
                  },
                  child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
          ...searches.map((search) => InkWell(
            onTap: () {
              _searchController.text = search;
              _performSearch(search);
              _focusNode.unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(child: Text(search, style: const TextStyle(fontSize: 15))),
                  const Icon(Icons.north_west, size: 16, color: Colors.grey),
                ],
              ),
            ),
          )),
        ],
     );
  }

  Widget _buildScrollableCenter(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}
