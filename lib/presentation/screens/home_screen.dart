import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/photo_providers.dart';
import '../providers/user_preferences_providers.dart';
import '../widgets/masonry_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosState = ref.watch(homeFeedProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final tabs = ref.watch(homeTabsProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Category Tabs
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: tabs.map((tab) {
                  return _buildTab(context, ref, tab, selectedCategory == tab);
                }).toList(),
              ),
            ),
            // Grid
            Expanded(
              child: photosState.when(
                data: (photos) {
                  // Trigger tag discovery if we are on the 'All' feed
                  if (selectedCategory == 'All' && photos.isNotEmpty) {
                    Future.microtask(() {
                      ref.read(discoveredTagsProvider.notifier).extractTagsFromPhotos(photos);
                    });
                  }

                  if (photos.isEmpty) {
                    return const Center(child: Text('No photos found'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(homeFeedProvider.notifier).refresh();
                    },
                    child: MasonryGrid(
                      photos: photos,
                      onLoadMore: () {
                        ref.read(homeFeedProvider.notifier).loadMore();
                      },
                    ),
                  );
                },
                loading: () => MasonryGrid(photos: const [], isLoading: true),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, WidgetRef ref, String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = text;
      },
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        alignment: Alignment.center,
        decoration: isSelected ? const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black, width: 3)),
        ) : null,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
