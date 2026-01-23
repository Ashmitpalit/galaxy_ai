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
          // Messages Section
          _buildSectionHeader('Messages', 'See all'),
          _buildMessageItem(
            'Ashmit',
            'You: Gargi shared off Pinterest',
            '4mo',
            'A',
            Colors.green[100]!,
          ),
          _buildMessageItem(
            'Piyush Kumar Rai',
            'Tai click Hye jaye',
            '1y',
            'P',
            Colors.orange[100]!,
            imageUrl: 'https://picsum.photos/100?random=1',
          ),
          _buildMessageItem(
            'Pinterest India',
            'Sent a Pin!',
            '4y',
            'P',
            Colors.red,
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
            'Try searching for more ideas to get inspired',
            '17h',
          ),
          _buildUpdateItem(
            'Still searching? Explore ideas related to Blue Shapes To Add In Background',
            '18h',
          ),
          _buildUpdateItem(
            'Ideas you\'ve been eyeing',
            '1d',
            isIdea: true,
            imageUrls: ['https://picsum.photos/100?random=2'],
          ),
          _buildUpdateItem(
            'Try searching for more ideas to get inspired',
            '2d',
          ),
           _buildUpdateItem(
            'Ideas you\'ve been eyeing',
            '2d',
            isIdea: true,
            imageUrls: [
              'https://picsum.photos/100?random=3', 
              'https://picsum.photos/100?random=4',
              'https://picsum.photos/100?random=5',
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
                    : Text(initial, style: const TextStyle(color: Colors.black87, fontSize: 20)))
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
          Text(
            time,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
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
