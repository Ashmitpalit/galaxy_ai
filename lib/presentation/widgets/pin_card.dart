import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/models/photo_model.dart';
import 'pin_shimmer.dart';

class PinCard extends StatelessWidget {
  final PhotoModel photo;
  final double aspectRatio;
  
  const PinCard({
    super.key,
    required this.photo,
    this.aspectRatio = 0.7,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            context.push('/pin/${photo.id}', extra: photo);
          },
          child: Hero(
            tag: 'photo_${photo.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16), // Updated to match screenshot
              child: CachedNetworkImage(
                imageUrl: photo.src.medium,
                memCacheWidth: 700,
                fit: BoxFit.cover,
                placeholder: (context, url) => PinShimmer(
                  height: 200 + (photo.height / photo.width) * 50,
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.more_horiz, size: 20, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
