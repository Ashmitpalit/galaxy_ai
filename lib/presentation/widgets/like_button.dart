import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LikeButton extends StatefulWidget {
  final bool isLiked;
  final int count;
  final VoidCallback onToggle;
  final double size;
  final bool showCount;

  const LikeButton({
    super.key,
    required this.isLiked,
    required this.count,
    required this.onToggle,
    this.size = 28,
    this.showCount = true,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked && !oldWidget.isLiked) {
      // Animate if becoming liked
      _controller.forward().then((_) => _controller.reverse());
      HapticFeedback.lightImpact(); // Use standard Flutter Service
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              widget.isLiked ? Icons.favorite : Icons.favorite_border,
              color: widget.isLiked ? Colors.red : Colors.black,
              size: widget.size,
            ),
          ),
          if (widget.showCount) ...[
            const SizedBox(width: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                 return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                '${widget.count}',
                key: ValueKey(widget.count),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
