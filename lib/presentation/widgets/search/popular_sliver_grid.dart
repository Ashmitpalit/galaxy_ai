import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../providers/photo_providers.dart';
import '../../../core/constants/ui_constants.dart';
import '../pin_card.dart';
import '../pin_shimmer.dart';
import '../../../data/models/photo_model.dart';
import '../../../domain/repositories/photo_repository.dart';

final popularPinsProvider = FutureProvider<List<PhotoModel>>((ref) async {
  final repository = ref.read(photoRepositoryProvider);
  return repository.getCuratedPhotos(page: 3); // Populated content
});

class PopularSliverGrid extends ConsumerWidget {
  const PopularSliverGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(popularPinsProvider);

    return popularAsync.when(
      data: (photos) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverMasonryGrid.count(
          crossAxisCount: UIConstants.gridCrossAxisCount,
          mainAxisSpacing: UIConstants.gridSpacing,
          crossAxisSpacing: UIConstants.gridSpacing,
          childCount: photos.length,
          itemBuilder: (context, index) {
            return PinCard(photo: photos[index]);
          },
        ),
      ),
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverMasonryGrid.count(
          crossAxisCount: UIConstants.gridCrossAxisCount,
          mainAxisSpacing: UIConstants.gridSpacing,
          crossAxisSpacing: UIConstants.gridSpacing,
          childCount: 6,
          itemBuilder: (context, index) {
            return const PinShimmer(height: 200);
          },
        ),
      ),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
    );
  }
}
