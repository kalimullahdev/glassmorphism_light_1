import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium glassmorphism card widget with dynamic lighting support
class GlassCard extends StatefulWidget {
  final Widget child;
  final double lightIntensity;
  final Offset lightPosition;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double glassThickness;
  final double width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.lightIntensity = 0.0,
    this.lightPosition = const Offset(0.5, 0.0),
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.all(28),
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.glassThickness = 2.0,
    this.width = double.infinity,
    this.height,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final glow = widget.lightIntensity;
    final br = widget.borderRadius;

    // Calculate highlight position based on light source
    final highlightAlignment = Alignment(
      (widget.lightPosition.dx - 0.5) * 2,
      (widget.lightPosition.dy - 0.5) * 2,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: widget.margin,
        width: widget.width,
        height: widget.height,
        transform: _isHovered
            ? (Matrix4.identity()
              ..translateByDouble(0.0, -4.0, 0.0, 1.0)
              ..scaleByDouble(1.01, 1.01, 1.0, 1.0))
            : Matrix4.identity(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(br),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(br),
                // Multi-layer glass effect
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.08 + glow * 0.12),
                    Colors.white.withValues(alpha: 0.03 + glow * 0.06),
                    Colors.white.withValues(alpha: 0.01 + glow * 0.03),
                    Colors.white.withValues(alpha: 0.05 + glow * 0.08),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
                border: Border.all(
                  width: widget.glassThickness,
                  color: Color.lerp(
                    Colors.white.withValues(alpha: 0.1),
                    const Color(0xFFFFF0CC).withValues(alpha: 0.35),
                    glow,
                  )!,
                ),
                boxShadow: [
                  // Outer shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3 + glow * 0.1),
                    blurRadius: 30 + glow * 20,
                    offset: Offset(0, 8 + glow * 4),
                    spreadRadius: -5,
                  ),
                  // Light reflection on top edge
                  if (glow > 0.05)
                    BoxShadow(
                      color: Color.fromRGBO(255, 230, 160, glow * 0.15),
                      blurRadius: 40,
                      offset: const Offset(0, -10),
                      spreadRadius: -10,
                    ),
                  // Ambient glow
                  if (glow > 0.05)
                    BoxShadow(
                      color: Color.fromRGBO(255, 220, 130, glow * 0.08),
                      blurRadius: 60,
                      spreadRadius: -5,
                    ),
                  // Hover glow
                  if (_isHovered)
                    BoxShadow(
                      color: Color.fromRGBO(
                        glow > 0.3 ? 255 : 150,
                        glow > 0.3 ? 220 : 180,
                        glow > 0.3 ? 130 : 255,
                        0.12,
                      ),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Specular highlight overlay
                  if (glow > 0.05)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(br - widget.glassThickness),
                            gradient: RadialGradient(
                              center: highlightAlignment,
                              radius: 1.5,
                              colors: [
                                Color.fromRGBO(255, 240, 190, glow * 0.12),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Top edge shine
                  Positioned(
                    top: 0,
                    left: 20,
                    right: 20,
                    child: IgnorePointer(
                      child: Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.15 + glow * 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  widget.child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
