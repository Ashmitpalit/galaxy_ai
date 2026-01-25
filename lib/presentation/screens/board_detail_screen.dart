import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/boards_provider.dart';
import '../providers/saved_pins_provider.dart';
import '../widgets/masonry_grid.dart';
import '../../data/models/photo_model.dart';

class BoardDetailScreen extends ConsumerWidget {
  final String boardId;
  
  const BoardDetailScreen({
    super.key,
    required this.boardId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(boardsProvider.notifier).getBoardById(boardId);
    final savedPins = ref.watch(savedPinsProvider);
    
    if (board == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text('Board not found')),
      );
    }
    
    // Get pins for this board
    final boardPins = board.pinIds
        .map((pinId) => savedPins[pinId])
        .where((pin) => pin != null)
        .cast<PhotoModel>()
        .toList();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          board.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: boardPins.isEmpty
          ? const Center(
              child: Text(
                'No pins in this board yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : MasonryGrid(
              photos: boardPins,
              boardId: boardId, // Pass board ID for context-specific unpinning
            ),
    );
  }
}
