import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/ui_constants.dart';

import '../providers/photo_providers.dart';
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
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchPhotosProvider);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ),
      body: searchState.when(
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
                    children: [
                      _buildSuggestionChip('Nature'),
                      _buildSuggestionChip('Architecture'),
                      _buildSuggestionChip('Food'),
                      _buildSuggestionChip('Travel'),
                      _buildSuggestionChip('Fashion'),
                      _buildSuggestionChip('Technology'),
                    ],
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
      labelStyle: const TextStyle(color: Colors.black87),
    );
  }
}
