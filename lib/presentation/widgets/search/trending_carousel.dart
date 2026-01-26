import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/models/photo_model.dart';
import '../../providers/photo_providers.dart';

final trendingPhotosProvider = FutureProvider<List<PhotoModel>>((ref) async {
  final repository = ref.read(photoRepositoryProvider);
  // Fetch trending/curated photos. "Trending" in Pexels is essentially curated.
  // We fetch a specific page/count to ensure variety from the main feed if desired.
  // Or we can search for "trending".
  return repository.getCuratedPhotos(page: 5); 
});

class TrendingCarousel extends ConsumerWidget {
  const TrendingCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendingAsync = ref.watch(trendingPhotosProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Trending on Pinterest',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: trendingAsync.when(
            data: (photos) => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () => context.push('/pin/${photo.id}', extra: photo),
                  child: Container(
                     width: 120,
                     margin: const EdgeInsets.symmetric(horizontal: 4),
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(16),
                       image: DecorationImage(
                         image: CachedNetworkImageProvider(photo.src.medium),
                         fit: BoxFit.cover,
                       ),
                     ),
                     child: Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(16),
                         gradient: LinearGradient(
                           begin: Alignment.bottomCenter,
                           end: Alignment.topCenter,
                           colors: [
                             Colors.black.withOpacity(0.6),
                             Colors.transparent,
                           ],
                         ),
                       ),
                       alignment: Alignment.bottomLeft,
                       padding: const EdgeInsets.all(8),
                       child: Text(
                         _shortenCaption(photo.alt),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                         style: const TextStyle(
                           color: Colors.white,
                           fontWeight: FontWeight.w600,
                           fontSize: 12,
                         ),
                       ),
                     ),
                  ),
                );
              },
            ),
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 5,
              itemBuilder: (context, index) => Container(
                width: 120,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ),
      ],
    );
  }

  String _shortenCaption(String? caption) {
    if (caption == null || caption.isEmpty) return 'Trending';
    final words = caption.split(' ');
    if (words.length > 3) {
      return '${words.take(3).join(' ')}...';
    }
    return caption;
  }
}
