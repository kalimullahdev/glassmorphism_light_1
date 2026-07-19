import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium toggle button styled as a futuristic glass switch
class LightToggleButton extends StatefulWidget {
  final bool isOn;
  final double lightIntensity;
  final VoidCallback onToggle;

  const LightToggleButton({
    super.key,
    required this.isOn,
    required this.lightIntensity,
    required this.onToggle,
  });

  @override
  State<LightToggleButton> createState() => _LightToggleButtonState();
}

class _LightToggleButtonState extends State<LightToggleButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = widget.lightIntensity;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse = _pulseController.value;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [
                    Colors.white.withValues(alpha: 0.12 + glow * 0.1),
                    Colors.white.withValues(alpha: 0.04 + glow * 0.05),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
                border: Border.all(
                  width: 2.0,
                  color: widget.isOn
                      ? Color.fromRGBO(255, 220, 130, 0.5 + pulse * 0.15)
                      : Colors.white.withValues(
                          alpha: 0.12 + (_isHovered ? 0.08 : 0),
                        ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                    spreadRadius: -4,
                  ),
                  if (widget.isOn)
                    BoxShadow(
                      color: Color.fromRGBO(255, 210, 100, 0.2 + pulse * 0.1),
                      blurRadius: 30 + pulse * 10,
                      spreadRadius: -2,
                    ),
                  if (_isHovered)
                    BoxShadow(
                      color: widget.isOn
                          ? const Color.fromRGBO(255, 210, 100, 0.15)
                          : Colors.white.withValues(alpha: 0.08),
                      blurRadius: 20,
                      spreadRadius: -2,
                    ),
                ],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glass inner highlight
                      Positioned(
                        top: 6,
                        left: 10,
                        right: 20,
                        child: Container(
                          height: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(
                                  alpha: 0.15 + glow * 0.1,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Power icon
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.power_settings_new_rounded,
                          key: ValueKey(widget.isOn),
                          size: 30,
                          color: widget.isOn
                              ? Color.fromRGBO(
                                  255,
                                  (210 + 30 * pulse).round(),
                                  (100 + 40 * pulse).round(),
                                  0.9 + pulse * 0.1,
                                )
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
