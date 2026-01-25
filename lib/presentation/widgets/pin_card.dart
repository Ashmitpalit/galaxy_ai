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
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            context.push('/pin/${widget.photo.id}', extra: widget.photo);
          },
          onLongPressStart: (details) {
            _showContextMenu(context, details.globalPosition);
          },
          child: Hero(
            tag: 'photo_${widget.photo.id}',
            child: ClipRRect(
              key: _imageKey,
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: widget.photo.src.medium,
                memCacheWidth: 700,
                fit: BoxFit.cover,
                placeholder: (context, url) => PinShimmer(
                  height: 200 + (widget.photo.height / widget.photo.width) * 50,
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
          onTap: () {
            // Get the position of the three-dot button
            final RenderBox? buttonBox = context.findRenderObject() as RenderBox?;
            if (buttonBox != null) {
              final buttonPosition = buttonBox.localToGlobal(Offset.zero);
              // Trigger the same context menu as long-press
              _showContextMenu(context, buttonPosition);
            }
          },
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: Icon(Icons.more_horiz, size: 20, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
