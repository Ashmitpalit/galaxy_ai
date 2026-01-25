import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/boards_provider.dart';
import '../providers/saved_pins_provider.dart';
import '../widgets/masonry_grid.dart';
import '../widgets/board_collage_cover.dart';
import '../widgets/delete_board_dialog.dart';

class SavedItemsScreen extends ConsumerStatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  ConsumerState<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends ConsumerState<SavedItemsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortOrder = 'Most recent'; // 'Most recent' or 'Oldest first'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Changed from 3 to 2
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with avatar and tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  // Profile avatar (clickable)
                  GestureDetector(
                    onTap: () => context.push('/account-settings'),
                    child: _buildProfileAvatar(),
                  ),
                  const SizedBox(width: 16),
                  // Tabs
                  Expanded(
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      tabs: const [
                        Tab(text: 'Pins'),
                        Tab(text: 'Boards'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Sort filter only - centered
            Center(
              child: GestureDetector(
                onTap: _showSortOptions,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swap_vert, size: 16, color: Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        _sortOrder,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPinsTab(),
                  _buildBoardsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    try {
      final user = ClerkAuth.userOf(context);
      if (user != null) {
        if (user.imageUrl != null) {
          return CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(user.imageUrl!),
          );
        } else {
          final email = user.emailAddresses?.firstOrNull?.emailAddress;
          final username = user.username ?? email?.split('@').first ?? 'U';
          final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';
          return CircleAvatar(
            radius: 20,
            backgroundColor: Colors.red,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Clerk not available
    }
    
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[300],
      child: const Icon(Icons.person, color: Colors.grey, size: 20),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _sortOrder == 'Most recent' ? Icons.check : null,
                  color: Colors.black,
                ),
                title: const Text('Most recent'),
                onTap: () {
                  setState(() => _sortOrder = 'Most recent');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  _sortOrder == 'Oldest first' ? Icons.check : null,
                  color: Colors.black,
                ),
                title: const Text('Oldest first'),
                onTap: () {
                  setState(() => _sortOrder = 'Oldest first');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPinsTab() {
    final savedPins = ref.watch(savedPinsProvider);
    var pins = savedPins.values.toList();
    
    if (pins.isEmpty) {
      return const SizedBox.shrink(); // Show nothing when empty
    }
    
    // Sort pins based on selected order
    // Note: Pins don't have timestamps yet, so we'll sort by ID as a proxy
    // In a real app, you'd add a savedAt timestamp to track when pins were saved
    if (_sortOrder == 'Oldest first') {
      pins = pins.reversed.toList();
    }
    
    return MasonryGrid(photos: pins);
  }

  Widget _buildBoardsTab() {
    var boards = ref.watch(boardsProvider);
    final savedPins = ref.watch(savedPinsProvider);

    if (boards.isEmpty) {
      return const SizedBox.shrink(); // Show nothing when empty
    }

    // Sort boards based on selected order
    if (_sortOrder == 'Oldest first') {
      boards = boards.reversed.toList();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: boards.length,
      itemBuilder: (context, index) {
        final board = boards[index];
        
        // Get up to 3 pin images for collage
        final imageUrls = board.pinIds
            .take(3)
            .map((pinId) => savedPins[pinId]?.src.medium)
            .where((url) => url != null)
            .cast<String>()
            .toList();
        
        return _buildBoardCard(
          board.id,
          board.name,
          board.pinIds.length,
          imageUrls,
        );
      },
    );
  }

  Widget _buildBoardCard(String boardId, String name, int pinCount, List<String> imageUrls) {
    return GestureDetector(
      onTap: () => context.push('/board/$boardId'),
      onLongPress: () async {
        final board = ref.read(boardsProvider.notifier).getBoardById(boardId);
        if (board != null) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => DeleteBoardDialog(board: board),
          );
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Board deleted')),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[100],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: BoardCollageCover(imageUrls: imageUrls),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$pinCount Pin${pinCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
