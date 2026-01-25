import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/boards_provider.dart';
import '../providers/saved_pins_provider.dart';
import '../../data/models/photo_model.dart';
import 'create_board_dialog.dart';

class BoardSelectionDialog extends ConsumerWidget {
  final PhotoModel photo;
  
  const BoardSelectionDialog({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(boardsProvider);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Save to board',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Create new board button
            InkWell(
              onTap: () async {
                Navigator.pop(context);
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => CreateBoardDialog(photo: photo),
                );
                if (result == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pin saved!')),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Create new board',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Existing boards list
            if (boards.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No boards yet. Create one to save pins!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: boards.length,
                  itemBuilder: (context, index) {
                    final board = boards[index];
                    return InkWell(
                      onTap: () async {
                        // Save pin to this board
                        await ref.read(boardsProvider.notifier).addPinToBoard(
                          board.id,
                          photo.id.toString(),
                        );
                        
                        // Save photo to saved pins
                        await ref.read(savedPinsProvider.notifier).savePin(photo);
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Saved to ${board.name}')),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.dashboard, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    board.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${board.pinIds.length} pin${board.pinIds.length == 1 ? '' : 's'}',
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
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
