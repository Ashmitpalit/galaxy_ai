import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/collection_model.dart';

class CollectionCard extends StatelessWidget {
  final CollectionModel collection;
  final VoidCallback? onTap;

  const CollectionCard({
    super.key,
    required this.collection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Cover Image
          AspectRatio(
            aspectRatio: 1, // Square or slightly landscape
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.grey[200],
                child: collection.coverImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: collection.coverImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )
                    : const Center(child: Icon(Icons.collections, color: Colors.grey)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            collection.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          // Pin Count
          Text(
            '${collection.pinCount} pins',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
