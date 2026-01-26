import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Likes ---

// Use a Set to store IDs of liked pins
final likedPinsProvider = StateNotifierProvider<LikedPinsNotifier, Set<String>>((ref) {
  return LikedPinsNotifier();
});

class LikedPinsNotifier extends StateNotifier<Set<String>> {
  LikedPinsNotifier() : super({});

  bool isLiked(String pinId) => state.contains(pinId);

  void toggleLike(String pinId) {
    if (state.contains(pinId)) {
      state = {...state}..remove(pinId);
    } else {
      state = {...state}..add(pinId);
    }
  }
}

// Derived provider for checking specific pin status
final isPinLikedProvider = Provider.family<bool, String>((ref, pinId) {
  final likedPins = ref.watch(likedPinsProvider);
  return likedPins.contains(pinId);
});


// --- Like Counts (Simulation) ---

// In a real app, this would come from the server. 
// Here we simulate it by hashing the ID to get a stable fake count, 
// and adding 1 if the user liked it locally.
final likeCountProvider = Provider.family<int, String>((ref, pinId) {
  final isLiked = ref.watch(isPinLikedProvider(pinId));
  // Stable random-ish number based on ID
  final baseCount = (pinId.hashCode % 100).abs() + 10;
  return isLiked ? baseCount + 1 : baseCount;
});


// --- Comments ---

class CommentModel {
  final String id;
  final String text;
  final String username;
  final String? timeAgo;
  final String? userImageUrl;

  CommentModel({
    required this.id,
    required this.text,
    required this.username,
    this.timeAgo = 'Just now',
    this.userImageUrl,
  });
}

final commentsProvider = StateNotifierProvider<CommentsNotifier, Map<String, List<CommentModel>>>((ref) {
  return CommentsNotifier();
});

class CommentsNotifier extends StateNotifier<Map<String, List<CommentModel>>> {
  CommentsNotifier() : super({});

  List<CommentModel> getComments(String pinId) {
    return state[pinId] ?? [];
  }

  void addComment(String pinId, String text, {String username = 'You'}) {
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      username: username,
      timeAgo: 'Just now',
    );

    final currentComments = state[pinId] ?? [];
    
    state = {
      ...state,
      pinId: [newComment, ...currentComments],
    };
  }
}

final pinCommentsProvider = Provider.family<List<CommentModel>, String>((ref, pinId) {
  final allComments = ref.watch(commentsProvider);
  return allComments[pinId] ?? [];
});

final commentCountProvider = Provider.family<int, String>((ref, pinId) {
  final comments = ref.watch(pinCommentsProvider(pinId));
  // Stable random-ish number base
  final baseCount = (pinId.hashCode % 10).abs(); 
  return baseCount + comments.length;
});
