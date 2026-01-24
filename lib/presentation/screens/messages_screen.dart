import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inbox',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Placeholder Banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              border: Border.all(color: Colors.amber[700]!, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[900], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This is a placeholder page with sample content',
                    style: TextStyle(
                      color: Colors.amber[900],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Messages Section
          _buildSectionHeader('Messages', 'See all'),
          _buildMessageItem(
            'Emma Wilson',
            'You: Thanks for sharing that idea!',
            '2h',
            'E',
            Colors.purple[100]!,
          ),
          _buildMessageItem(
            'Design Studio',
            'Check out our latest collection',
            '5h',
            'D',
            Colors.blue[100]!,
          ),
          _buildMessageItem(
            'Creative Hub',
            'Sent a Pin!',
            '1d',
            'C',
            const Color(0xFFE60023),
            isPinterest: true,
          ),
          
          const SizedBox(height: 32),
          
          // Updates Section
          const Text(
            'Updates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildUpdateItem(
            'Discover new ideas for your next project',
            '3h',
          ),
          _buildUpdateItem(
            'Trending: Modern minimalist interior design',
            '6h',
          ),
          _buildUpdateItem(
            'Ideas you might like',
            '12h',
            isIdea: true,
            imageUrls: ['https://picsum.photos/200/300?random=10'],
          ),
          _buildUpdateItem(
            'Popular in your area: Home decor inspiration',
            '1d',
          ),
           _buildUpdateItem(
            'Saved for later',
            '2d',
            isIdea: true,
            imageUrls: [
              'https://picsum.photos/200/300?random=11', 
              'https://picsum.photos/200/300?random=12',
              'https://picsum.photos/200/300?random=13',
              ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Row(
            children: [
              Text(
                action,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.chevron_right, color: Colors.black, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(
    String name,
    String message,
    String time,
    String initial,
    Color color, {
    String? imageUrl,
    bool isPinterest = false,
    bool hasUnread = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? (isPinterest
                    ? const Icon(Icons.push_pin, color: Colors.white, size: 32)
                    : Text(initial, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (hasUnread) ...[
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE60023),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(String text, String time, {bool isIdea = false, List<String>? imageUrls}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: isIdea && imageUrls != null && imageUrls.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(imageUrls.first, fit: BoxFit.cover),
                )
              : const Icon(Icons.search, size: 28, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(fontSize: 16, height: 1.3),
                ),
                if (imageUrls != null && imageUrls.length > 1) ...[
                   const SizedBox(height: 8),
                   // Tiny collage placeholder
                   Row(
                     children: imageUrls.take(3).map((url) => Padding(
                       padding: const EdgeInsets.only(right: 4),
                       child: ClipRRect(
                         borderRadius: BorderRadius.circular(8),
                         child: Image.network(url, width: 40, height: 40, fit: BoxFit.cover),
                       ),
                     )).toList(),
                   )
                ]
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
