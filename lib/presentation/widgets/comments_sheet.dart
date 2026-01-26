import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/interaction_provider.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String pinId;

  const CommentsSheet({
    super.key,
    required this.pinId,
  });

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _textController = TextEditingController();

  void _postComment() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      ref.read(commentsProvider.notifier).addComment(widget.pinId, text);
      _textController.clear();
      // Scroll to top? Or list updates automatically.
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(pinCommentsProvider(widget.pinId));
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    // Some mock data mixed with real
    final allComments = [
      ...comments,
       // Adding some fake base comments for UI fullness if empty, 
       // but typically we'd fetch this. For now let's just use user provider comments
       // plus maybe a generic one if empty to show UI.
       if (comments.isEmpty) 
         CommentModel(id: 'mock', text: 'Love this look! 😍', username: 'Sarah', timeAgo: '2h'),
    ];

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SafeArea(
        bottom: bottomInset == 0, // Avoid double padding when keyboard is open
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Comments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            
            // List
            Expanded(
              child: allComments.isEmpty 
               ? const Center(child: Text('No comments yet. Be the first!'))
               : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allComments.length,
                  itemBuilder: (context, index) {
                    final comment = allComments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: comment.userImageUrl != null 
                              ? NetworkImage(comment.userImageUrl!) 
                              : null,
                            child: comment.userImageUrl == null 
                              ? Text(comment.username[0].toUpperCase()) 
                              : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment.username,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      comment.timeAgo ?? '',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(comment.text),
                              ],
                            ),
                          ),
                          const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                        ],
                      ),
                    );
                  },
                ),
            ),
            
            const Divider(height: 1),
            // Input
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                     radius: 16,
                     backgroundColor: Colors.grey, // Current user avatar placeholder
                     child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _postComment,
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
