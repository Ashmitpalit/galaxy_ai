import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/models/photo_model.dart';
import 'pin_card.dart';
import 'pin_shimmer.dart';

class MasonryGrid extends StatefulWidget {
  final List<PhotoModel> photos;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  
  const MasonryGrid({
    super.key,
    required this.photos,
    this.onLoadMore,
    this.isLoading = false,
  });
  
  @override
  State<MasonryGrid> createState() => _MasonryGridState();
}

class _MasonryGridState extends State<MasonryGrid> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 500) {
      widget.onLoadMore?.call();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      controller: _scrollController,
      crossAxisCount: UIConstants.gridCrossAxisCount,
      mainAxisSpacing: UIConstants.gridSpacing,
      crossAxisSpacing: UIConstants.gridSpacing,
      padding: const EdgeInsets.all(UIConstants.gridSpacing),
      itemCount: widget.photos.length + (widget.isLoading ? 4 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.photos.length) {
          return const PinShimmer(height: 250);
        }
        
        return PinCard(photo: widget.photos[index]);
      },
      cacheExtent: 1000,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
    );
  }
}
