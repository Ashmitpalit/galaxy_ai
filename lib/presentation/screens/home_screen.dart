import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../providers/photo_providers.dart';
import '../providers/user_preferences_providers.dart';
import '../widgets/pin_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosState = ref.watch(homeFeedProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final tabs = ref.watch(homeTabsProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(homeFeedProvider.notifier).refresh();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Floating App Bar with Tabs
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: true,
                backgroundColor: Colors.white,
                elevation: 0,
                toolbarHeight: 0, // Hide default toolbar
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: tabs.map((tab) {
                        return _buildTab(context, ref, tab, selectedCategory == tab);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              
              // Content Grid
              photosState.when(
                data: (photos) {
                  // Trigger tag discovery if we are on the 'All' feed
                  if (selectedCategory == 'All' && photos.isNotEmpty) {
                    Future.microtask(() {
                      ref.read(discoveredTagsProvider.notifier).extractTagsFromPhotos(photos);
                    });
                  }

                  if (photos.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('No photos found')),
                      ),
                    );
                  }
                  
                  return SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childCount: photos.length,
                      itemBuilder: (context, index) {
                        // Check if we need to load more
                        if (index == photos.length - 2) {
                          Future.microtask(() {
                             ref.read(homeFeedProvider.notifier).loadMore();
                          });
                        }
                        return PinCard(photo: photos[index]);
                      },
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                   child: Container(
                     height: 200, 
                     alignment: Alignment.center,
                     child: const CircularProgressIndicator()
                   )
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $error')),
                ),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: const EdgeInsets.only(right: 8),
        alignment: Alignment.center,
        decoration: isSelected 
          ? BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
            )
          : null,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
