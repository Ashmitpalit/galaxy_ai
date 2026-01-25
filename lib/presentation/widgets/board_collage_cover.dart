import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BoardCollageCover extends StatelessWidget {
  final List<String> imageUrls;
  
  const BoardCollageCover({
    super.key,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      // Empty state - gray placeholder
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.dashboard_outlined,
            size: 48,
            color: Colors.grey,
          ),
        ),
      );
    } else if (imageUrls.length == 1) {
      // Single image
      return CachedNetworkImage(
        imageUrl: imageUrls[0],
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error, color: Colors.grey),
        ),
      );
    } else {
      // Pinterest-style collage: 1 large left, 2 small stacked right
      return Row(
        children: [
          // Large image on left (2/3 width)
          Expanded(
            flex: 2,
            child: CachedNetworkImage(
              imageUrl: imageUrls[0],
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, size: 24, color: Colors.grey),
              ),
            ),
          ),
          // Two small images stacked on right (1/3 width)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Top small image
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: imageUrls.length > 1 ? imageUrls[1] : imageUrls[0],
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 16, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                // Bottom small image
                Expanded(
                  child: CachedNetworkImage(
                    imageUrl: imageUrls.length > 2 ? imageUrls[2] : imageUrls[0],
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 16, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
