import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MovingBackgroundCollage extends ConsumerStatefulWidget {
  const MovingBackgroundCollage({super.key});

  @override
  ConsumerState<MovingBackgroundCollage> createState() => _MovingBackgroundCollageState();
}

class _MovingBackgroundCollageState extends ConsumerState<MovingBackgroundCollage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  final ScrollController _scrollController3 = ScrollController();
  
  // List of local asset paths
  final List<String> _photos = List.generate(
    18, 
    (index) => 'assets/canvas/${index + 1}.jpg'
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Tick duration (irrelevant for unbounded)
    )..repeat();

    _controller.addListener(_scroll);
    
    // Initial scroll offset to stagger the columns
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController2.hasClients) {
        _scrollController2.jumpTo(100);
      }
      if (_scrollController3.hasClients) {
        _scrollController3.jumpTo(200);
      }
    });
  }
  

  @override
  void dispose() {
    _controller.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    super.dispose();
  }

  void _scroll() {
    const double speed = 0.5; // Pixels per frame approx
    
    _scrollOne(_scrollController1, speed);
    _scrollOne(_scrollController2, -speed); // Scroll down
    _scrollOne(_scrollController3, speed);
  }
  
  void _scrollOne(ScrollController controller, double offset) {
    if (!controller.hasClients) return;
    
    double maxExtent = controller.position.maxScrollExtent;
    double currentOffset = controller.offset;
    double newOffset = currentOffset + offset;
    
    // Loop around logic
    if (newOffset >= maxExtent) {
      newOffset = 0; // Jump to start
      controller.jumpTo(newOffset);
    } else if (newOffset <= 0) {
      newOffset = maxExtent; // Jump to end
      controller.jumpTo(newOffset);
    } else {
      controller.jumpTo(newOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Split photos into 3 columns (6 each)
    final int third = (_photos.length / 3).ceil();
    final col1 = _photos.sublist(0, third);
    final col2 = _photos.sublist(third, third * 2);
    final col3 = _photos.sublist(third * 2);

    return Opacity(
      opacity: 0.8, // Slight fade for background feel
      child: Row(
        children: [
          Expanded(child: _buildInfiniteColumn(_scrollController1, col1)),
          const SizedBox(width: 8),
          Expanded(child: _buildInfiniteColumn(_scrollController2, col2, reverse: true)),
          const SizedBox(width: 8),
          Expanded(child: _buildInfiniteColumn(_scrollController3, col3)),
        ],
      ),
    );
  }

  Widget _buildInfiniteColumn(ScrollController controller, List<String> photoPaths, {bool reverse = false}) {
    return ListView.builder(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      // Make it effectively infinite by looping same items
      itemCount: photoPaths.length * 1000, 
      itemBuilder: (context, index) {
        final path = photoPaths[index % photoPaths.length];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 9/16, // Enforce vertical aspect
              child: Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
