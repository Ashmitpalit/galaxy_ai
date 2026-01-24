import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/ui_constants.dart';

import '../providers/photo_providers.dart';
import '../providers/user_preferences_providers.dart';
import '../widgets/masonry_grid.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchPhotosProvider.notifier).search(query.trim());
      // Record search history for Home Tabs
      ref.read(searchHistoryProvider.notifier).addSearch(query.trim());
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchPhotosProvider);
    final searchHistory = ref.watch(searchHistoryProvider.notifier);
    final recentSearches = searchHistory.getRecentSearches(10);
    final personalizedPredictions = ref.watch(homeTabsProvider).where((tag) => tag != 'All').take(6).toList();
    
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
                        setState(() {});
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                    onPressed: () {
                      // Camera functionality placeholder
                    },
                  ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // Search History Dropdown (shown when focused)
          if (_focusNode.hasFocus && recentSearches.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Searches',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await searchHistory.clearAll();
                            setState(() {});
                          },
                          child: const Text(
                            'Clear All',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...recentSearches.map((search) => InkWell(
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
                          Expanded(
                            child: Text(
                              search,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          const Icon(Icons.north_west, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          
          // Main Content
          Expanded(
            child: searchState.when(
              data: (photos) {
                if (photos.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                
                if (photos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Search for ideas',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: personalizedPredictions.map((tag) => _buildSuggestionChip(tag)).toList(),
                        ),
                      ],
                    ),
                  );
                }
                
                return MasonryGrid(
                  photos: photos,
                  onLoadMore: () {
                    ref.read(searchPhotosProvider.notifier).loadMore();
                  },
                );
              },
              loading: () => MasonryGrid(
                photos: const [],
                isLoading: true,
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _searchController.text = label;
        _performSearch(label);
      },
      backgroundColor: Colors.grey[200],
      labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
