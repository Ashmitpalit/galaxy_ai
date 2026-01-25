import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/photo_model.dart';
import '../providers/saved_pins_provider.dart';
import '../providers/boards_provider.dart';
import '../widgets/board_selection_dialog.dart';

class PinDetailScreen extends ConsumerWidget {
  final PhotoModel photo;
  
  const PinDetailScreen({
    super.key,
    required this.photo,
  });
  
  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    
    final pinId = photo.id.toString();
    final isPinned = ref.read(boardsProvider.notifier).isPinSaved(pinId);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.search, size: 20),
              ),
              title: const Text('Find similar'),
              subtitle: const Text('Search for similar images'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Finding similar images...')),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share_outlined, size: 20),
              ),
              title: const Text('Share'),
              subtitle: const Text('Share this pin'),
              onTap: () {
                Navigator.pop(context);
                _sharePhoto(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 20,
                ),
              ),
              title: Text(isPinned ? 'Unpin' : 'Save to board'),
              subtitle: Text(isPinned ? 'Remove from all boards' : 'Save this pin'),
              onTap: () async {
                Navigator.pop(context);
                
                if (isPinned) {
                  // Unpin logic
                  final boards = ref.read(boardsProvider.notifier).getBoardsContainingPin(pinId);
                  for (final board in boards) {
                    await ref.read(boardsProvider.notifier).removePinFromBoard(board.id, pinId);
                  }
                  await ref.read(savedPinsProvider.notifier).unsavePin(pinId);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pin removed from all boards')),
                    );
                  }
                } else {
                  // Show board selection
                  if (context.mounted) {
                    await showDialog(
                      context: context,
                      builder: (context) => BoardSelectionDialog(photo: photo),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if pin is saved globally
    final savedPins = ref.watch(savedPinsProvider);
    final isSaved = savedPins.containsKey(photo.id.toString());
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
            ),
            onPressed: () => _showOptionsMenu(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Hero(
                tag: 'photo_${photo.id}',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: photo.src.large2x,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      color: Color(
                        int.parse('FF${photo.avgColor.substring(1)}', radix: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            
                            if (isSaved) {
                              // Show unsave options
                              final pinId = photo.id.toString();
                              final boards = ref.read(boardsProvider.notifier).getBoardsContainingPin(pinId);
                              
                              showModalBottomSheet(
                                context: context,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                builder: (context) => Container(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Text(
                                          'Remove pin from:',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ...boards.map((board) => ListTile(
                                        leading: const Icon(Icons.dashboard),
                                        title: Text(board.name),
                                        subtitle: const Text('Remove from this board'),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await ref.read(boardsProvider.notifier).removePinFromBoard(board.id, pinId);
                                          
                                          // Check if still in other boards
                                          final stillPinned = ref.read(boardsProvider.notifier).isPinSaved(pinId);
                                          if (!stillPinned) {
                                            await ref.read(savedPinsProvider.notifier).unsavePin(pinId);
                                          }
                                          
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Removed from ${board.name}')),
                                            );
                                          }
                                        },
                                      )),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.delete_outline, color: Colors.red),
                                        title: const Text(
                                          'Remove from all boards',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onTap: () async {
                                          Navigator.pop(context);
                                          
                                          for (final board in boards) {
                                            await ref.read(boardsProvider.notifier).removePinFromBoard(board.id, pinId);
                                          }
                                          await ref.read(savedPinsProvider.notifier).unsavePin(pinId);
                                          
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Pin removed from all boards')),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              // Show board selection to save
                              await showDialog(
                                context: context,
                                builder: (context) => BoardSelectionDialog(photo: photo),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSaved ? Colors.grey[300] : AppTheme.pinterestRed,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: Icon(
                            isSaved ? Icons.push_pin : Icons.push_pin_outlined,
                            size: 20,
                            color: isSaved ? Colors.grey[700] : Colors.white,
                          ),
                          label: Text(
                            isSaved ? 'Saved' : 'Save',
                            style: TextStyle(
                              fontSize: 16,
                              color: isSaved ? Colors.grey[700] : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          _sharePhoto(context);
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.share, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Text(
                          photo.photographer[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              photo.photographer,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'Photographer',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Follow'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        '${photo.width} × ${photo.height}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _sharePhoto(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copy link'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download image'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
