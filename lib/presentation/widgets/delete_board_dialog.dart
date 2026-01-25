import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/boards_provider.dart';
import '../providers/saved_pins_provider.dart';
import '../../data/models/board_model.dart';

class DeleteBoardDialog extends ConsumerWidget {
  final BoardModel board;
  
  const DeleteBoardDialog({
    super.key,
    required this.board,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinCount = board.pinIds.length;
    final hasWarning = pinCount > 0;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete board?'),
      content: hasWarning
          ? Text(
              'Your $pinCount saved pin${pinCount == 1 ? '' : 's'} will be removed.',
              style: const TextStyle(fontSize: 16),
            )
          : null,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Delete board and unsave all pins
            final savedPins = ref.read(savedPinsProvider);
            
            // For each pin in the board
            for (final pinId in board.pinIds) {
              // Remove from this board
              await ref.read(boardsProvider.notifier).removePinFromBoard(board.id, pinId);
              
              // Check if pin exists in any other board
              final isPinInOtherBoards = ref.read(boardsProvider.notifier).isPinSaved(pinId);
              
              // If not in any other board, remove from saved pins
              if (!isPinInOtherBoards) {
                await ref.read(savedPinsProvider.notifier).unsavePin(pinId);
              }
            }
            
            // Delete the board
            await ref.read(boardsProvider.notifier).deleteBoard(board.id);
            
            if (context.mounted) {
              Navigator.pop(context, true);
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
