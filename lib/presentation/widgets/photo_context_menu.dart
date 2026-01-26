import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../data/models/photo_model.dart';
import '../providers/boards_provider.dart';
import '../providers/saved_pins_provider.dart';
import '../providers/interaction_provider.dart';
import 'board_selection_dialog.dart';
import 'similar_photos_sheet.dart';

class PhotoContextMenu extends ConsumerStatefulWidget {
  final PhotoModel photo;
  final Offset position;
  final Size imageSize;
  final VoidCallback onDismiss;
  final String? boardId; // Optional: if provided, unpin from this board only

  const PhotoContextMenu({
    super.key,
    required this.photo,
    required this.position,
    required this.imageSize,
    required this.onDismiss,
    this.boardId,
  });

  @override
  ConsumerState<PhotoContextMenu> createState() => _PhotoContextMenuState();
}

class _PhotoContextMenuState extends ConsumerState<PhotoContextMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _blurAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleAction(String action) async {
    if (!mounted) return;

    switch (action) {
      case 'similar':
        await _controller.reverse();
        widget.onDismiss();
        
        // Show similar photos sheet
        if (context.mounted) {
           // Use alt text or fallback to generic term for search
           final query = widget.photo.alt ?? widget.photo.photographer;
           
           showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) => SimilarPhotosSheet(
                  query: query ?? 'nature', // Fallback if no alt or photographer
                  scrollController: scrollController,
                ),
              ),
            );
        }
        break;
      case 'like':
        final pinId = widget.photo.id.toString();
        ref.read(likedPinsProvider.notifier).toggleLike(pinId);
        
        // Give a short delay to see the change if we want, or just dismiss
        // For now, let's dismiss to keep flow fast
        await _controller.reverse();
        widget.onDismiss();
        break;
      case 'share':
        await _controller.reverse();
        widget.onDismiss();
        _showSnackBar('relax its just a pinterest clone 😂');
        break;
      case 'save':
        final pinId = widget.photo.id.toString();
        final isPinned = ref.read(boardsProvider.notifier).isPinSaved(pinId);
        
        if (isPinned) {
          // Unsave logic
          if (widget.boardId != null) {
            // Board-specific unpinning: Remove from THIS board only
            await ref.read(boardsProvider.notifier).removePinFromBoard(widget.boardId!, pinId);
            
            // Check if pin still exists in other boards
            final stillPinned = ref.read(boardsProvider.notifier).isPinSaved(pinId);
            
            // If not in any other board, remove from saved pins
            if (!stillPinned) {
              await ref.read(savedPinsProvider.notifier).unsavePin(pinId);
            }
            
            // Dismiss after state update
            await _controller.reverse();
            widget.onDismiss();
            
            if (mounted) {
              _showSnackBar('Removed from board');
            }
          } else {
            // Global unpinning: Remove from ALL boards
            final boards = ref.read(boardsProvider.notifier).getBoardsContainingPin(pinId);
            for (final board in boards) {
              await ref.read(boardsProvider.notifier).removePinFromBoard(board.id, pinId);
            }
            await ref.read(savedPinsProvider.notifier).unsavePin(pinId);
            
            // Dismiss after state update
            await _controller.reverse();
            widget.onDismiss();
            
            if (mounted) {
              _showSnackBar('Pin removed from all boards');
            }
          }
        } else {
          // Dismiss first for save action
          await _controller.reverse();
          widget.onDismiss();
          
          if (mounted) {
            // Save: Show board selection dialog
            await showDialog(
              context: context,
              builder: (context) => BoardSelectionDialog(photo: widget.photo),
            );
          }
        }
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _controller.reverse();
        widget.onDismiss();
      },
      child: AnimatedBuilder(
        animation: _blurAnimation,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _blurAnimation.value,
              sigmaY: _blurAnimation.value,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3 * _opacityAnimation.value),
              child: child,
            ),
          );
        },
        child: Stack(
          children: [
            // Elevated image - rendered first (bottom layer)
            Positioned(
              left: widget.position.dx,
              top: widget.position.dy,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 1.0, end: 1.1),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.imageSize.width,
                      height: widget.imageSize.height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: widget.photo.src.medium,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Buttons arranged in an arc - rendered second (top layer)
            ..._buildArcButtons(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildArcButtons() {
    final screenSize = MediaQuery.of(context).size;
    final centerX = widget.position.dx + widget.imageSize.width / 2;
    final centerY = widget.position.dy + widget.imageSize.height / 2;
    
    // Calculate dynamic radius based on image size
    // Use the larger dimension (width or height) as base, with min/max constraints
    final imageDiagonal = math.sqrt(
      widget.imageSize.width * widget.imageSize.width + 
      widget.imageSize.height * widget.imageSize.height
    );
    final baseRadius = imageDiagonal * 0.45; // 45% of diagonal
    final radius = baseRadius.clamp(100.0, 180.0); // Min 100, Max 180
    
    // Determine which side has more space
    final leftSpace = centerX;
    final rightSpace = screenSize.width - centerX;
    final topSpace = centerY;
    final bottomSpace = screenSize.height - centerY;
    
    // Decide button placement based on available space
    // Priority: side with most horizontal space
    final bool placeOnRight = rightSpace > leftSpace;
    
    // Calculate optimal arc angles based on placement and vertical space
    double startAngle;
    double sweepAngle = 2 * math.pi / 3; // 120 degrees
    
    if (placeOnRight) {
      // Place buttons on right side
      // If more space at top, bias upward; if more at bottom, bias downward
      if (topSpace > bottomSpace) {
        startAngle = -math.pi / 6; // Start at -30° (upper right)
      } else {
        startAngle = math.pi / 6; // Start at 30° (lower right)
      }
    } else {
      // Place buttons on left side
      if (topSpace > bottomSpace) {
        startAngle = 5 * math.pi / 6; // Start at 150° (upper left)
      } else {
        startAngle = 7 * math.pi / 6; // Start at 210° (lower left)
      }
    }
    
    final pinId = widget.photo.id.toString();
    final isPinned = ref.watch(boardsProvider.notifier).isPinSaved(pinId);
    final isLiked = ref.watch(isPinLikedProvider(pinId));
    
    final buttons = [
      {'icon': Icons.search, 'label': 'Similar', 'action': 'similar'},
      {
        'icon': isLiked ? Icons.favorite : Icons.favorite_border,
        'label': 'Like',
        'action': 'like',
        'color': isLiked ? Colors.red : Colors.black87,
      },
      {'icon': Icons.share_outlined, 'label': 'Share', 'action': 'share'},
      {
        'icon': isPinned ? Icons.push_pin : Icons.push_pin_outlined,
        'label': 'Save',
        'action': 'save'
      },
    ];

    return List.generate(buttons.length, (index) {
      final button = buttons[index];
      final angle = startAngle + (sweepAngle / (buttons.length - 1)) * index;
      
      // Calculate position on arc
      var x = centerX + radius * math.cos(angle) - 30;
      var y = centerY + radius * math.sin(angle) - 30;
      
      // Clamp to screen boundaries with padding
      x = x.clamp(10.0, screenSize.width - 70.0);
      y = y.clamp(60.0, screenSize.height - 130.0);

      return Positioned(
        left: x,
        top: y,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildActionButton(
              icon: button['icon'] as IconData,
              label: button['label'] as String,
              color: button.containsKey('color') ? button['color'] as Color : Colors.black87,
              onTap: () => _handleAction(button['action'] as String),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 28,
            color: color,
          ),
        ),
      ),
    );
  }
}
