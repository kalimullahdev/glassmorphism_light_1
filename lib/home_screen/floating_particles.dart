import 'dart:math';
import 'package:flutter/material.dart';

/// Animated floating particles that react to light
class FloatingParticles extends StatefulWidget {
  final double lightIntensity;
  final Size size;

  const FloatingParticles({
    super.key,
    required this.lightIntensity,
    required this.size,
  });

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _particles = List.generate(40, (_) => _Particle(_random));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: widget.size,
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            lightIntensity: widget.lightIntensity,
          ),
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;
  final double driftX;

  _Particle(Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        size = 1.5 + r.nextDouble() * 3.0,
        speed = 0.2 + r.nextDouble() * 0.8,
        phase = r.nextDouble() * 2 * pi,
        driftX = (r.nextDouble() - 0.5) * 0.3;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final double lightIntensity;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.lightIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final x = (p.x + sin(t * 2 * pi) * p.driftX) * size.width;
      final y = ((p.y + t) % 1.0) * size.height;

      // Distance from light source (top center)
      final lightCenterX = size.width / 2;
      final dist = sqrt(pow(x - lightCenterX, 2) + pow(y, 2));
      final maxDist = sqrt(pow(size.width / 2, 2) + pow(size.height, 2));
      final proximity = 1.0 - (dist / maxDist).clamp(0.0, 1.0);

      final baseAlpha = 0.05 + lightIntensity * 0.15 * proximity;
      final particleSize = p.size * (1.0 + lightIntensity * proximity * 0.5);

      final paint = Paint()
        ..color = Color.fromRGBO(
          (200 + lightIntensity * 55 * proximity).round().clamp(0, 255),
          (200 + lightIntensity * 40 * proximity).round().clamp(0, 255),
          (220 + lightIntensity * 20 * proximity).round().clamp(0, 255),
          baseAlpha.clamp(0.0, 0.5),
        );

      canvas.drawCircle(Offset(x, y), particleSize, paint);

      // Light sparkle effect
      if (lightIntensity > 0.3 && proximity > 0.5) {
        final sparklePaint = Paint()
          ..color = Color.fromRGBO(255, 240, 200, lightIntensity * proximity * 0.2)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize * 2);
        canvas.drawCircle(Offset(x, y), particleSize * 1.5, sparklePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
