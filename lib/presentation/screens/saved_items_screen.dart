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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                        Tab(text: 'Collages'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search bar and filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Search your saved ideas',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: Colors.black, size: 30),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip('Sort', hasDropdown: true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Group'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Archived'),
                ],
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
                  _buildCollagesTab(),
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

  Widget _buildFilterChip(String label, {bool hasDropdown = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDropdown) ...[
            const Icon(Icons.swap_vert, size: 16, color: Colors.black),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinsTab() {
    final savedPins = ref.watch(savedPinsProvider);
    final pins = savedPins.values.toList();
    
    if (pins.isEmpty) {
      return const SizedBox.shrink(); // Show nothing when empty
    }
    
    return MasonryGrid(photos: pins);
  }

  Widget _buildBoardsTab() {
    final boards = ref.watch(boardsProvider);
    final savedPins = ref.watch(savedPinsProvider);

    if (boards.isEmpty) {
      return const SizedBox.shrink(); // Show nothing when empty
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

  Widget _buildCollagesTab() {
    // Empty for now - show nothing
    return const SizedBox.shrink();
  }
}
