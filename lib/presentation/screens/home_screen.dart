import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/photo_providers.dart';
import '../widgets/masonry_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosState = ref.watch(curatedPhotosProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pinterest',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: photosState.when(
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(
              child: Text('No photos found'),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(curatedPhotosProvider.notifier).refresh();
            },
            child: MasonryGrid(
              photos: photos,
              onLoadMore: () {
                ref.read(curatedPhotosProvider.notifier).loadMore();
              },
            ),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(curatedPhotosProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
