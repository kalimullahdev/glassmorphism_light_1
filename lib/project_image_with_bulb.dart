import 'package:flutter/material.dart';
import 'light_bulb_painter.dart';

/// A premium interactive widget that adds a mini hanging bulb and light cone
/// overlay on top of the project showcase image, reacting to hover and global light state.
class ProjectImageWithBulb extends StatefulWidget {
  final String imagePath;
  final double mainGlow;

  const ProjectImageWithBulb({
    super.key,
    required this.imagePath,
    required this.mainGlow,
  });

  @override
  State<ProjectImageWithBulb> createState() => _ProjectImageWithBulbState();
}

class _ProjectImageWithBulbState extends State<ProjectImageWithBulb>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Warm, organic pulse effect for the filament glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the target glow based on page state or card hover
    final targetGlow = widget.mainGlow > 0.1
        ? widget.mainGlow
        : (_isHovered ? 0.9 : 0.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: targetGlow),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (context, glowValue, child) {
          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              // Apply flicker/pulse simulation to filament and cone intensity
              final pulse = _pulseController.value;
              final effectiveGlow = glowValue * (0.93 + pulse * 0.07);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. The Project Image
                  Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black.withValues(alpha: 0.2),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white.withValues(alpha: 0.2),
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),

                  // 2. Dark Room Overlay (dims the image when the bulb is OFF)
                  IgnorePointer(
                    child: Container(
                      color: Colors.black.withValues(
                        alpha: (1.0 - effectiveGlow).clamp(0.0, 1.0) * 0.78,
                      ),
                    ),
                  ),

                  // 2. Light Cone Overlay (Visual beam shining down from top-center)
                  if (effectiveGlow > 0.01) ...[
                    // Soft light beam (Linear gradient spreading down)
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(
                                0xFFFFD54F,
                              ).withValues(alpha: effectiveGlow * 0.26),
                              const Color(
                                0xFFFFB74D,
                              ).withValues(alpha: effectiveGlow * 0.06),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Hot spot highlight (Radial gradient at the bulb source)
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topCenter,
                            radius: 0.8,
                            colors: [
                              const Color(
                                0xFFFFF9C4,
                              ).withValues(alpha: effectiveGlow * 0.45),
                              const Color(
                                0xFFFFE082,
                              ).withValues(alpha: effectiveGlow * 0.12),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // 3. Premium Glass Reflections / Highlights (Subtle ambient sheen that fades smoothly)
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(
                              alpha: 0.03 + effectiveGlow * 0.02,
                            ),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3],
                        ),
                      ),
                    ),
                  ),

                  // 4. Subtle Inner border to reinforce glass depth
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.2,
                          color: Color.lerp(
                            Colors.white.withValues(alpha: 0.08),
                            const Color(0xFFFFD54F).withValues(alpha: 0.22),
                            effectiveGlow,
                          )!,
                        ),
                        // borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  // 5. Mini Hanging Light Bulb
                  Positioned(
                    top: -12, // Hanging from the top border of the card
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: SizedBox(
                          width: 44,
                          height: 56,
                          child: CustomPaint(
                            painter: LightBulbPainter(
                              glowIntensity: effectiveGlow,
                              flickerValue: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
