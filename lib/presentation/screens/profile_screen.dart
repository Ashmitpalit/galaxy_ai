import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../data/models/photo_model.dart';
import '../../data/models/collection_model.dart';
import '../widgets/masonry_grid.dart';
import '../widgets/profile_header.dart';
import '../widgets/collection_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap ONLY profile screen with ClerkAuth
    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: dotenv.env['CLERK_PUBLISHABLE_KEY']!,
      ),
      child: const _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final mockPhotos = List.generate(
      10,
      (index) => PhotoModel(
        id: index,
        width: 1000,
        height: index % 2 == 0 ? 1500 : 1000,
        url: 'https://example.com',
        photographer: 'User $index',
        avgColor: '#E0E0E0',
        src: PhotoSrc(
          original: 'https://picsum.photos/500/800?random=$index',
          large2x: 'https://picsum.photos/500/800?random=$index',
          large: 'https://picsum.photos/500/800?random=$index',
          medium: 'https://picsum.photos/500/800?random=$index',
          small: 'https://picsum.photos/500/800?random=$index',
          portrait: 'https://picsum.photos/500/800?random=$index',
          landscape: 'https://picsum.photos/500/800?random=$index',
          tiny: 'https://picsum.photos/500/800?random=$index',
        ),
      ),
    );

    // Mock Collections
    final mockCollections = List.generate(
      5,
      (index) => CollectionModel(
        id: 'col_$index',
        title: index == 0 ? 'All Pins' : 'Collection $index',
        coverImageUrl: 'https://picsum.photos/500/500?random=${index + 100}',
        pinCount: (index + 1) * 12,
        previewImageUrls: [],
      ),
    );

    return Scaffold(
      body: DefaultTabController(
        length: 3, // Pins, Boards, Collages
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              const SliverToBoxAdapter(
                child: SafeArea(
                  child: ProfileHeader(),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    tabs: [
                      Tab(text: 'Pins'),
                      Tab(text: 'Boards'),
                      Tab(text: 'Collages'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // Pins Tab
               _buildContentTab(context, mockPhotos, true),
              // Boards Tab
               _buildBoardsTab(mockCollections),
              // Collages Tab
               const Center(child: Text('No collages yet')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentTab(BuildContext context, List<PhotoModel> photos, bool isPins) {
    return Column(
      children: [
        // Search Bar & Filter
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
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
                icon: const Icon(Icons.add, size: 30),
              ),
            ],
          ),
        ),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('Group'),
              const SizedBox(width: 8),
              _buildFilterChip('Archived'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Grid
        Expanded(
          child: MasonryGrid(
            photos: photos,
            isLoading: false,
          ),
        ),
      ],
    );
  }

  Widget _buildBoardsTab(List<CollectionModel> collections) {
     return Column(
      children: [
         // Search Bar & Filter (Duplicated for tab consistency, or could receive as param)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
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
                icon: const Icon(Icons.add, size: 30),
              ),
            ],
          ),
        ),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('Group'),
              const SizedBox(width: 8),
              _buildFilterChip('Archived'),
            ],
          ),
        ),
        const SizedBox(height: 16),
         Expanded(
           child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: collections.length,
            itemBuilder: (context, index) {
              return CollectionCard(collection: collections[index]);
            },
          ),
         ),
      ],
     );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (label == 'Group') ...[
             const Icon(Icons.swap_vert, size: 16),
             const SizedBox(width: 4),
          ],
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
