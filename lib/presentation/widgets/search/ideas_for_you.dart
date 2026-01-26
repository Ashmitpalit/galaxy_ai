import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../providers/photo_providers.dart';
import '../../../data/models/photo_model.dart';
import '../../providers/user_preferences_providers.dart';

final ideasForYouProvider = FutureProvider<List<PhotoModel>>((ref) async {
  final repository = ref.read(photoRepositoryProvider);
  // Trigger rebuilds when history changes
  ref.watch(searchHistoryProvider);
  final historyNotifier = ref.read(searchHistoryProvider.notifier);
  
  String query = 'creative'; // Default fall back
  final recent = historyNotifier.getRecentSearches(1);
  if (recent.isNotEmpty) {
     query = recent.first;
  }
  
  // Fetch some nice ideas
  return repository.searchPhotos(query: query, page: 2);
});

class IdeasForYou extends ConsumerWidget {
  const IdeasForYou({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideasAsync = ref.watch(ideasForYouProvider);
    // Correctly get the most recent topic for display title
    final historyNotifier = ref.watch(searchHistoryProvider.notifier);
    final recent = historyNotifier.getRecentSearches(1);
    final topic = recent.isNotEmpty ? recent.first : 'Creative';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Ideas for you',
             style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ideasAsync.when(
          data: (photos) => SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return GestureDetector(
                   onTap: () => context.push('/pin/${photo.id}', extra: photo),
                   child: Container(
                    width: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: photo.src.medium,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          photo.photographer, // Mock title using photographer/alt
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                   ),
                );
              },
            ),
          ),
          loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }
}
