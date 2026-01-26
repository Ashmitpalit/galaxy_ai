import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/models/photo_model.dart';
import 'pin_shimmer.dart';
import 'photo_context_menu.dart';

class PinCard extends StatefulWidget {
  final PhotoModel photo;
  final double aspectRatio;
  final String? boardId; // Optional board ID for context-specific actions
  
  const PinCard({
    super.key,
    required this.photo,
    this.aspectRatio = 0.7,
    this.boardId,
  });

  @override
  State<PinCard> createState() => _PinCardState();
}

class _PinCardState extends State<PinCard> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _imageKey = GlobalKey();

  void _showContextMenu(BuildContext context, Offset globalPosition) {
    // Trigger haptic feedback
    HapticFeedback.mediumImpact();

    // Get the image's render box to calculate size and position
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final imageSize = renderBox.size;
    final imagePosition = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => PhotoContextMenu(
        photo: widget.photo,
        position: imagePosition,
        imageSize: imageSize,
        onDismiss: _removeContextMenu,
        boardId: widget.boardId, // Pass board ID for context-specific unpinning
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeContextMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeContextMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            context.push('/pin/${widget.photo.id}', extra: widget.photo);
          },
          onLongPressStart: (details) {
            _showContextMenu(context, details.globalPosition);
          },
          // Add scale effect or specialized touch feedback/Hero logic here if desired
          child: Hero(
            tag: 'photo_${widget.photo.id}',
            child: ClipRRect(
              key: _imageKey,
              borderRadius: BorderRadius.circular(12), // Smoother radius
              child: CachedNetworkImage(
                imageUrl: widget.photo.src.medium,
                memCacheWidth: 700,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                   color: Color(int.parse('FF${widget.photo.avgColor.substring(1)}', radix: 16)),
                   height: 200, // Placeholder
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Title and Options Row
        Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Expanded(
               child: Text(
                 widget.photo.alt ?? '',
                 maxLines: 2,
                 overflow: TextOverflow.ellipsis,
                 style: const TextStyle(
                   fontSize: 12,
                   fontWeight: FontWeight.w600,
                   color: Colors.black87,
                 ),
               ),
             ),
             InkWell(
              onTap: () {
                final RenderBox? buttonBox = context.findRenderObject() as RenderBox?;
                if (buttonBox != null) {
                  final buttonPosition = buttonBox.localToGlobal(Offset.zero);
                  _showContextMenu(context, buttonPosition);
                }
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Icon(Icons.more_horiz, size: 16, color: Colors.black54),
              ),
            ),
           ],
        ),
      ],
    );
  }
}
