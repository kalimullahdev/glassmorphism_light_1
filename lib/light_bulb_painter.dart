import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter for the realistic hanging light bulb
class LightBulbPainter extends CustomPainter {
  final double glowIntensity;
  final double flickerValue;

  LightBulbPainter({
    required this.glowIntensity,
    this.flickerValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bulbCenterY = size.height * 0.62;
    final bulbRadius = size.width * 0.16;
    final effectiveGlow = glowIntensity * flickerValue;

    // --- Draw the wire/cord ---
    final wirePaint = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, bulbCenterY - bulbRadius * 2.1),
      wirePaint,
    );

    // --- Draw the metal cap/base (Edison screw) ---
    _drawMetalCap(canvas, centerX, bulbCenterY - bulbRadius * 1.55, bulbRadius, effectiveGlow);

    // --- Draw outer glow when ON ---
    if (effectiveGlow > 0.01) {
      for (int i = 8; i >= 1; i--) {
        final glowRadius = bulbRadius * (1.0 + i * 0.8);
        final opacity = (effectiveGlow * 0.06 / i).clamp(0.0, 0.15);
        final glowPaint = Paint()
          ..color = Color.fromRGBO(255, 220, 130, opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius * 0.5);
        canvas.drawCircle(
          Offset(centerX, bulbCenterY),
          glowRadius,
          glowPaint,
        );
      }
    }

    // --- Draw the glass bulb ---
    _drawGlassBulb(canvas, centerX, bulbCenterY, bulbRadius, effectiveGlow);

    // --- Draw the filament ---
    _drawFilament(canvas, centerX, bulbCenterY, bulbRadius, effectiveGlow);

    // --- Draw light rays when ON ---
    if (effectiveGlow > 0.1) {
      _drawLightRays(canvas, centerX, bulbCenterY, bulbRadius, effectiveGlow);
    }
  }

  void _drawMetalCap(Canvas canvas, double cx, double cy, double bulbRadius, double glow) {
    final capWidth = bulbRadius * 1.1;
    final capHeight = bulbRadius * 0.7;
    final capRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: capWidth, height: capHeight),
      Radius.circular(capWidth * 0.12),
    );

    // Metal gradient
    final metalGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.lerp(const Color(0xFF888888), const Color(0xFFBBBB99), glow * 0.3)!,
        Color.lerp(const Color(0xFF444444), const Color(0xFF776633), glow * 0.3)!,
        Color.lerp(const Color(0xFF666666), const Color(0xFF998855), glow * 0.3)!,
        Color.lerp(const Color(0xFF333333), const Color(0xFF554422), glow * 0.3)!,
      ],
      stops: const [0.0, 0.35, 0.65, 1.0],
    );

    final metalPaint = Paint()
      ..shader = metalGradient.createShader(capRect.outerRect);
    canvas.drawRRect(capRect, metalPaint);

    // Screw threads
    final threadPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final y = cy - capHeight * 0.3 + i * (capHeight * 0.18);
      canvas.drawLine(
        Offset(cx - capWidth * 0.4, y),
        Offset(cx + capWidth * 0.4, y),
        threadPaint,
      );
    }

    // Metallic highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15 + glow * 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(
      Offset(cx - capWidth * 0.3, cy - capHeight * 0.35),
      Offset(cx + capWidth * 0.1, cy - capHeight * 0.35),
      highlightPaint..strokeWidth = 2.0,
    );
  }

  void _drawGlassBulb(Canvas canvas, double cx, double cy, double radius, double glow) {
    // Bulb shape using path (pear shape)
    final bulbPath = Path();
    final neckY = cy - radius * 1.05;
    final neckWidth = radius * 0.35;

    bulbPath.moveTo(cx - neckWidth, neckY);
    bulbPath.cubicTo(
      cx - radius * 1.1, neckY + radius * 0.5,
      cx - radius * 1.15, cy + radius * 0.3,
      cx, cy + radius * 1.1,
    );
    bulbPath.cubicTo(
      cx + radius * 1.15, cy + radius * 0.3,
      cx + radius * 1.1, neckY + radius * 0.5,
      cx + neckWidth, neckY,
    );
    bulbPath.close();

    // Glass fill - transparent with warm tint when on
    final glassFill = Paint()
      ..style = PaintingStyle.fill;

    if (glow > 0.01) {
      glassFill.shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Color.fromRGBO(255, 240, 180, 0.15 + glow * 0.35),
          Color.fromRGBO(255, 210, 100, 0.08 + glow * 0.2),
          Color.fromRGBO(255, 200, 80, 0.03 + glow * 0.1),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius * 1.2));
    } else {
      glassFill.shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.03),
          Colors.white.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius * 1.2));
    }

    canvas.drawPath(bulbPath, glassFill);

    // Glass edge/outline
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Color.fromRGBO(
        200 + (55 * glow).round(),
        200 + (40 * glow).round(),
        200,
        0.15 + glow * 0.2,
      );
    canvas.drawPath(bulbPath, edgePaint);

    // Glass reflection highlight (specular)
    final reflectionPath = Path();
    reflectionPath.moveTo(cx - radius * 0.5, cy - radius * 0.3);
    reflectionPath.quadraticBezierTo(
      cx - radius * 0.7, cy + radius * 0.1,
      cx - radius * 0.3, cy + radius * 0.5,
    );
    reflectionPath.quadraticBezierTo(
      cx - radius * 0.5, cy + radius * 0.1,
      cx - radius * 0.35, cy - radius * 0.25,
    );
    reflectionPath.close();

    final reflectionPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.12 + glow * 0.08),
          Colors.white.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    canvas.drawPath(reflectionPath, reflectionPaint);
  }

  void _drawFilament(Canvas canvas, double cx, double cy, double radius, double glow) {
    final filamentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    if (glow > 0.01) {
      filamentPaint.color = Color.fromRGBO(
        255,
        (180 + 75 * glow).round().clamp(0, 255),
        (50 + 100 * glow).round().clamp(0, 255),
        0.6 + glow * 0.4,
      );
      // Filament glow
      final filGlow = Paint()
        ..color = Color.fromRGBO(255, 200, 100, glow * 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 + glow * 4);
      _drawFilamentShape(canvas, cx, cy, radius, filGlow);
    } else {
      filamentPaint.color = const Color(0xFF555555);
    }

    _drawFilamentShape(canvas, cx, cy, radius, filamentPaint);
  }

  void _drawFilamentShape(Canvas canvas, double cx, double cy, double radius, Paint paint) {
    final path = Path();
    final startY = cy - radius * 0.55;
    final endY = cy + radius * 0.35;
    final segments = 8;
    final segHeight = (endY - startY) / segments;
    final amplitude = radius * 0.15;

    // Support wires
    canvas.drawLine(
      Offset(cx - radius * 0.15, cy - radius * 0.85),
      Offset(cx - radius * 0.08, startY),
      paint,
    );
    canvas.drawLine(
      Offset(cx + radius * 0.15, cy - radius * 0.85),
      Offset(cx + radius * 0.08, startY),
      paint,
    );

    // Coiled filament
    path.moveTo(cx - radius * 0.08, startY);
    for (int i = 0; i < segments; i++) {
      final y1 = startY + i * segHeight + segHeight * 0.5;
      final y2 = startY + (i + 1) * segHeight;
      final xOff = (i % 2 == 0) ? amplitude : -amplitude;
      path.quadraticBezierTo(cx + xOff, y1, cx, y2);
    }

    canvas.drawPath(path, paint);
  }

  void _drawLightRays(Canvas canvas, double cx, double cy, double radius, double glow) {
    final rayCount = 16;
    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * pi;
      final innerR = radius * 1.3;
      final outerR = radius * (2.0 + sin(i * 1.5) * 0.5);
      final opacity = (glow * 0.04 * (0.5 + sin(i * 2.1) * 0.5)).clamp(0.0, 0.08);

      final rayPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color.fromRGBO(255, 230, 150, opacity),
            Color.fromRGBO(255, 220, 120, 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: outerR))
        ..strokeWidth = radius * 0.12
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(cx + cos(angle) * innerR, cy + sin(angle) * innerR),
        Offset(cx + cos(angle) * outerR, cy + sin(angle) * outerR),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant LightBulbPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.flickerValue != flickerValue;
  }
}
