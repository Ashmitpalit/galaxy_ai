import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:math' as math;

import '../../core/theme/app_theme.dart';
import '../../data/models/photo_model.dart';
import '../providers/saved_pins_provider.dart';
import '../providers/boards_provider.dart';
import '../providers/photo_providers.dart';
import '../providers/interaction_provider.dart';
import '../widgets/board_selection_dialog.dart';
import '../widgets/pin_card.dart';
import '../widgets/pin_shimmer.dart';
import '../widgets/like_button.dart';
import '../widgets/comments_sheet.dart';

class PinDetailScreen extends ConsumerStatefulWidget {
  final PhotoModel photo;
  
  const PinDetailScreen({
    super.key,
    required this.photo,
  });

  @override
  ConsumerState<PinDetailScreen> createState() => _PinDetailScreenState();
}

class _PinDetailScreenState extends ConsumerState<PinDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Similar photos state
  List<PhotoModel> _similarPhotos = [];
  bool _isLoadingSimilar = true;
  
  @override
  void initState() {
    super.initState();
    _loadSimilarPhotos();
  }
  
  Future<void> _loadSimilarPhotos() async {
    try {
      final repository = ref.read(photoRepositoryProvider);
      final query = widget.photo.alt ?? widget.photo.photographer;
      final photos = await repository.searchPhotos(
        query: query ?? 'nature',
        page: 1,
      );
      
      if (mounted) {
        setState(() {
          _similarPhotos = photos;
          _isLoadingSimilar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSimilar = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _showShareSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Transparent for custom look
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black, // Dark theme as per screenshot
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Save or share Pin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 48), // Spacer for centering
              ],
            ),
            const SizedBox(height: 20),
            // Image Preview
            Center(
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(widget.photo.src.large),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
             Center(
              child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Icon(Icons.link, color: Colors.white70, size: 16),
                   const SizedBox(width: 4),
                   Text(
                    'Pinterest.com',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                 ]
              ),
            ),
            const SizedBox(height: 30),
            // Action Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareAction(Icons.push_pin, 'Save', onTap: () {
                    Navigator.pop(context);
                    _savePin(context);
                }),
                // Collage removed as requested
                _buildShareAction(Icons.chat_bubble_outline, 'WhatsApp', color: Colors.green, onTap: () => _showRelaxToast(context)),
                _buildShareAction(Icons.message_outlined, 'Messenger', color: Colors.blue, onTap: () => _showRelaxToast(context)),
                _buildShareAction(Icons.message, 'Messages', color: Colors.green, onTap: () => _showRelaxToast(context)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 _buildShareAction(Icons.link, 'Copy link', onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.photo.url));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied!')),
                    );
                 }),
                 _buildShareAction(Icons.email_outlined, 'Message', onTap: () => _showRelaxToast(context)),
                 _buildShareAction(Icons.more_horiz, 'More apps', onTap: () => _showRelaxToast(context)),
                 // Spacer to keep grid alignment if needed, or just leave as is
                 const SizedBox(width: 60), 
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShareAction(IconData icon, String label, {Color? color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color ?? Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showRelaxToast(BuildContext context) {
    Navigator.pop(context); // Close sheet first
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('relax its just a pinterest clone 😂'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  Future<void> _savePin(BuildContext context) async {
      final pinId = widget.photo.id.toString();
      final isSaved = ref.read(savedPinsProvider).containsKey(pinId);

      if (isSaved) {
           // Already saved
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Already saved!')),
           );
      } else {
        await showDialog(
            context: context,
            builder: (context) => BoardSelectionDialog(photo: widget.photo),
        );
      }
  }

  void _showOptionsMenu(BuildContext context) {
    // Keep existing logic
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                _showShareSheet(context);
              },
            ),
             ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download image'),
              onTap: () {
                Navigator.pop(context);
                // Implementation for download
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Pin'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinId = widget.photo.id.toString();
    final isSaved = ref.watch(savedPinsProvider).containsKey(pinId);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar (Floating back button)
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
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
                onPressed: () => _showOptionsMenu(context),
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image
                   ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: CachedNetworkImage(
                      imageUrl: widget.photo.src.large2x,
                      fit: BoxFit.contain,
                       placeholder: (context, url) => AspectRatio(
                            aspectRatio: widget.photo.width/widget.photo.height,
                            child: Container(
                                color: Color(int.parse('FF${widget.photo.avgColor.substring(1)}', radix: 16)),
                            ),
                       ),
                    ),
                  ),
                  
                  // Action Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Icons
                        Row(
                          children: [
                            // Functional Like Button
                            Consumer(
                              builder: (context, ref, _) {
                                final isLiked = ref.watch(isPinLikedProvider(pinId));
                                final count = ref.watch(likeCountProvider(pinId));
                                return LikeButton(
                                  isLiked: isLiked,
                                  count: count,
                                  onToggle: () {
                                     ref.read(likedPinsProvider.notifier).toggleLike(pinId);
                                  },
                                );
                              },
                            ),
                            
                            const SizedBox(width: 20),
                            
                            // Functional Comment Button
                            Consumer(
                              builder: (context, ref, _) {
                                final count = ref.watch(commentCountProvider(pinId));
                                return GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => CommentsSheet(pinId: pinId),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.mode_comment_outlined, size: 26),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$count', 
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            const SizedBox(width: 20),
                            
                             IconButton(
                                icon: const Icon(Icons.share, size: 26),
                                onPressed: () => _showShareSheet(context),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        
                        // Save Button
                        ElevatedButton(
                          onPressed: () => _savePin(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSaved ? Colors.black : AppTheme.pinterestRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                             isSaved ? 'Saved' : 'Save',
                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Title/Desc
                  if (widget.photo.alt != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.photo.alt!,
                         style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                  // Author Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                         CircleAvatar(
                           backgroundColor: Colors.grey[200],
                           backgroundImage: widget.photo.photographerUrl != null 
                             ? NetworkImage(widget.photo.photographerUrl!) 
                             : null,
                           child: widget.photo.photographerUrl == null 
                             ? Text(widget.photo.photographer[0]) 
                             : null,
                         ),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                  widget.photo.photographer,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                               ),
                               const Text(
                                  'Followers 12k', // Mock
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                               ),
                             ],
                           ),
                         ),
                         OutlinedButton(
                           onPressed: () {},
                           style: OutlinedButton.styleFrom(
                             shape: const StadiumBorder(),
                           ),
                           child: const Text('Follow'),
                         ),
                      ],
                    ),
                  ),
                  
                  // More to explore
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: const Text(
                       'More to explore',
                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [ 'Protective', 'Coily', 'Curly', 'Wavy', 'Straight', 'Braids' ]
                        .map((tag) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Chip(
                             label: Text(tag),
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                             backgroundColor: Colors.grey[200],
                             side: BorderSide.none,
                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                             avatar: const Icon(Icons.search, size: 18),
                          ),
                        )).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Inline Masonry Grid for Similar Photos
          SliverPadding(
            padding: const EdgeInsets.all(8),
             sliver: _isLoadingSimilar
               ? SliverToBoxAdapter(
                  child: SizedBox(
                   height: 200, 
                   child: Center(child: CircularProgressIndicator())
                  )
                 )
               : SliverMasonryGrid.count(
                   crossAxisCount: 2,
                   mainAxisSpacing: 8,
                   crossAxisSpacing: 8,
                   childCount: _similarPhotos.length,
                   itemBuilder: (context, index) {
                     return PinCard(photo: _similarPhotos[index]);
                   },
               ),
          ),
          
           const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }
}
