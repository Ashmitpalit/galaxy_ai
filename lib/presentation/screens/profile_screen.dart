import 'package:flutter/material.dart';

import '../../data/models/photo_model.dart';
import '../../data/models/collection_model.dart';
import '../widgets/masonry_grid.dart';
import '../widgets/profile_header.dart';
import '../widgets/collection_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        length: 2,
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
                    tabs: [
                      Tab(text: 'Created'),
                      Tab(text: 'Saved'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              MasonryGrid(
                photos: mockPhotos,
                isLoading: false,
              ),
              // Saved / Collections Tab
              GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: mockCollections.length,
                itemBuilder: (context, index) {
                  return CollectionCard(collection: mockCollections[index]);
                },
              ),
            ],
          ),
        ),
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
