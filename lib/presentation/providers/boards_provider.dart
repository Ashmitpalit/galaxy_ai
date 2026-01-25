import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/board_model.dart';

// Provider for boards state
final boardsProvider = StateNotifierProvider<BoardsNotifier, List<BoardModel>>((ref) {
  return BoardsNotifier();
});

class BoardsNotifier extends StateNotifier<List<BoardModel>> {
  BoardsNotifier() : super([]) {
    _loadBoards();
  }

  static const String _storageKey = 'boards';

  // Load boards from storage
  Future<void> _loadBoards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final boardsJson = prefs.getString(_storageKey);
      
      if (boardsJson != null) {
        final List<dynamic> decoded = json.decode(boardsJson);
        state = decoded.map((json) => BoardModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle error
      state = [];
    }
  }

  // Save boards to storage
  Future<void> _saveBoards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final boardsJson = json.encode(state.map((board) => board.toJson()).toList());
      await prefs.setString(_storageKey, boardsJson);
    } catch (e) {
      // Handle error
    }
  }

  // Create a new board
  Future<BoardModel> createBoard(String name) async {
    final newBoard = BoardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      pinIds: [],
      createdAt: DateTime.now(),
    );
    
    state = [...state, newBoard];
    await _saveBoards();
    return newBoard;
  }

  // Delete a board
  Future<void> deleteBoard(String boardId) async {
    state = state.where((board) => board.id != boardId).toList();
    await _saveBoards();
  }

  // Get board by ID
  BoardModel? getBoardById(String boardId) {
    try {
      return state.firstWhere((board) => board.id == boardId);
    } catch (e) {
      return null;
    }
  }

  // Add pin to board
  Future<void> addPinToBoard(String boardId, String pinId) async {
    state = state.map((board) {
      if (board.id == boardId && !board.pinIds.contains(pinId)) {
        return board.copyWith(pinIds: [...board.pinIds, pinId]);
      }
      return board;
    }).toList();
    await _saveBoards();
  }

  // Remove pin from board
  Future<void> removePinFromBoard(String boardId, String pinId) async {
    state = state.map((board) {
      if (board.id == boardId) {
        return board.copyWith(
          pinIds: board.pinIds.where((id) => id != pinId).toList(),
        );
      }
      return board;
    }).toList();
    await _saveBoards();
  }

  // Get boards containing a specific pin
  List<BoardModel> getBoardsContainingPin(String pinId) {
    return state.where((board) => board.pinIds.contains(pinId)).toList();
  }

  // Check if pin is in any board
  bool isPinSaved(String pinId) {
    return state.any((board) => board.pinIds.contains(pinId));
  }
}
