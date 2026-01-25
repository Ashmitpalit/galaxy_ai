import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.animation, required this.particles})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final progress = animation.value;
      final x = particle.startX + particle.velocityX * progress;
      final y = particle.startY + particle.velocityY * progress + (progress * progress * 500); // Gravity
      
      final paint = Paint()
        ..color = particle.color.withOpacity((1 - progress).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation * progress * 10);
      
      if (particle.shape == ParticleShape.circle) {
        canvas.drawCircle(Offset.zero, particle.size, paint);
      } else if (particle.shape == ParticleShape.square) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: particle.size * 2, height: particle.size * 2),
          paint,
        );
      } else {
        // Triangle
        final path = Path()
          ..moveTo(0, -particle.size)
          ..lineTo(particle.size, particle.size)
          ..lineTo(-particle.size, particle.size)
          ..close();
        canvas.drawPath(path, paint);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}

enum ParticleShape { circle, square, triangle }

class ConfettiParticle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double size;
  final double rotation;
  final ParticleShape shape;

  ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.rotation,
    required this.shape,
  });
}

class ConfettiOverlay extends StatefulWidget {
  final Offset position;
  final VoidCallback onComplete;

  const ConfettiOverlay({
    super.key,
    required this.position,
    required this.onComplete,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 10000), // 10 FULL SECONDS!
      vsync: this,
    );

    _generateParticles();
    _controller.forward().then((_) => widget.onComplete());
  }

  void _generateParticles() {
    final random = math.Random();
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
    ];

    _particles = List.generate(40, (index) {
      final angle = (index / 40) * 2 * math.pi;
      final speed = 60 + random.nextDouble() * 40; // Much slower particles
      
      return ConfettiParticle(
        startX: widget.position.dx,
        startY: widget.position.dy,
        velocityX: math.cos(angle) * speed,
        velocityY: math.sin(angle) * speed - 80, // Slower initial upward velocity
        color: colors[random.nextInt(colors.length)],
        size: 3 + random.nextDouble() * 5,
        rotation: random.nextDouble() * 2 * math.pi,
        shape: ParticleShape.values[random.nextInt(ParticleShape.values.length)],
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConfettiPainter(
        animation: _controller,
        particles: _particles,
      ),
      child: Container(),
    );
  }
}
