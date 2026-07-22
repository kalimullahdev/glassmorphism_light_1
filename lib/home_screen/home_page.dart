import 'dart:math';

import 'package:flutter/material.dart';
import 'home_grid_content.dart';
import 'light_bulb_painter.dart';
import 'glass_card.dart';
import 'floating_particles.dart';
import 'light_toggle_button.dart';
import 'project_image_with_bulb.dart';
import 'detail_page.dart';
import 'shared_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isLightOn = false;
  late AnimationController _lightController;
  late AnimationController _flickerController;
  late final Animation<double> _lightAnimation;
  late final Animation<double> _flickerAnimation;

  // Background gradient animation
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _glowNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();

    _isLightOn = globalLightStateNotifier.value;
    globalLightStateNotifier.addListener(_onGlobalLightStateChanged);

    _lightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _lightAnimation = CurvedAnimation(
      parent: _lightController,
      curve: Curves.easeInOutCubic,
    );

    // Subtle flicker effect
    _flickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _flickerAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _flickerController, curve: Curves.easeInOut),
    );

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _bgAnimation = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOut,
    );

    _lightController.addListener(() {
      _glowNotifier.value = _lightAnimation.value;
    });

    if (_isLightOn) {
      _lightController.value = 1.0;
      _glowNotifier.value = 1.0;
    }
  }

  void _onGlobalLightStateChanged() {
    if (globalLightStateNotifier.value != _isLightOn) {
      setState(() {
        _isLightOn = globalLightStateNotifier.value;
      });
      if (_isLightOn) {
        _lightController.forward();
        _startFlicker();
      } else {
        _lightController.reverse();
      }
    }
  }

  @override
  void dispose() {
    globalLightStateNotifier.removeListener(_onGlobalLightStateChanged);
    _lightController.dispose();
    _flickerController.dispose();
    _bgController.dispose();
    _scrollController.dispose();
    _glowNotifier.dispose();
    super.dispose();
  }

  void _toggleLight() {
    globalLightStateNotifier.value = !globalLightStateNotifier.value;
  }

  void _startFlicker() async {
    while (_isLightOn && mounted) {
      await Future.delayed(
        Duration(milliseconds: 2000 + Random().nextInt(4000)),
      );
      if (!_isLightOn || !mounted) break;
      await _flickerController.forward();
      await _flickerController.reverse();
      if (Random().nextBool()) {
        await Future.delayed(const Duration(milliseconds: 80));
        if (!_isLightOn || !mounted) break;
        await _flickerController.forward();
        await _flickerController.reverse();
      }
    }
  }

  // Attenuate light based on depth to simulate realistic distance
  double _getAttenuatedGlow(double baseGlow, double depth) {
    return baseGlow * (1.0 - depth * 0.85).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // === BACKGROUND ===
          _buildBackground(),
          // === FLOATING PARTICLES ===
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ValueListenableBuilder<double>(
                    valueListenable: _glowNotifier,
                    builder: (context, glow, _) {
                      return FloatingParticles(
                        lightIntensity: glow * 0.8,
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // === SCROLLABLE ROOM CONTENT ===
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // === LIGHT CONE ===
                  ValueListenableBuilder<double>(
                    valueListenable: _glowNotifier,
                    builder: (context, glow, _) {
                      if (glow < 0.01) return const SizedBox.shrink();
                      return Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 3500,
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _LightConePainter(intensity: glow),
                          ),
                        ),
                      );
                    },
                  ),
                  // === MAIN CONTENT ===
                  _buildContent(),
                  // === LIGHT BULB ===
                  ValueListenableBuilder<double>(
                    valueListenable: _glowNotifier,
                    builder: (context, glow, _) {
                      return Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SizedBox(
                            width: 140,
                            height: 180,
                            child: CustomPaint(
                              painter: LightBulbPainter(
                                glowIntensity: _lightAnimation.value,
                                flickerValue: _flickerAnimation.value,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // === TOGGLE BUTTON ===
          Positioned(
            bottom: 32,
            right: 32,
            child: ValueListenableBuilder<double>(
              valueListenable: _glowNotifier,
              builder: (context, glow, _) {
                return LightToggleButton(
                  isOn: _isLightOn,
                  lightIntensity: glow,
                  onToggle: _toggleLight,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([_bgAnimation, _scrollController]),
        builder: (context, child) {
          final bgShift = _bgAnimation.value;
          final scrollOffset = _scrollController.hasClients
              ? _scrollController.offset
              : 0.0;
          final scrollShift = (scrollOffset * 0.0015).clamp(0.0, 1.5);

          return ValueListenableBuilder<double>(
            valueListenable: _glowNotifier,
            builder: (context, glow, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      0.0,
                      -0.6 + bgShift * 0.1 - scrollShift * 0.2,
                    ),
                    radius: 1.2 + glow * 0.5 + bgShift * 0.1,
                    colors: [
                      Color.lerp(
                        const Color(0xFF0A0A12),
                        const Color(0xFF1A1510),
                        glow * 0.5,
                      )!,
                      Color.lerp(
                        const Color(0xFF080810),
                        const Color(0xFF12100A),
                        glow * 0.4,
                      )!,
                      Color.lerp(
                        const Color(0xFF050508),
                        const Color(0xFF0A0806),
                        glow * 0.3,
                      )!,
                      const Color(0xFF020204),
                    ],
                    stops: [0.0, 0.3 + bgShift * 0.05, 0.65, 1.0],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    final lightPos = const Offset(0.5, 0.0);

    return Column(
      children: [
        const SizedBox(height: 200),
        ValueListenableBuilder<double>(
          valueListenable: _glowNotifier,
          builder: (context, glow, _) => buildGridContent(glow, context),
        ),
        const SizedBox(height: 40),
        ValueListenableBuilder<double>(
          valueListenable: _glowNotifier,
          builder: (context, glow, _) =>
              _buildProjectsSection(_getAttenuatedGlow(glow, 0.0), lightPos),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildProjectsSection(double glow, Offset lightPos) {
    final projects = const [
      (name: "Ming's Kitchen", image: "assets/mingskitchen.png"),
      (name: "Holedo", image: "assets/holedo.png"),
      (name: "Habit Tracker", image: "assets/habit_tracker.png"),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('PROJECTS', 'Plan. Build. Test. Deliver', glow),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 950
                  ? 3
                  : constraints.maxWidth > 600
                  ? 2
                  : 1;

              const spacing = 0.0;
              final totalSpacing = spacing * (crossAxisCount - 1);
              final cardWidth =
                  ((constraints.maxWidth - totalSpacing) / crossAxisCount) -
                  0.1;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: projects.map((project) {
                  final cardWidget = _buildProjectCard(
                    name: project.name,
                    imagePath: project.image,
                    glow: glow,
                    lightPos: lightPos,
                  );
                  return SizedBox(
                    width: cardWidth,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 600),
                              pageBuilder: (_, _, _) => DetailPage(
                                heroTag: 'hero_project_${project.name}',
                                child: cardWidget,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'hero_project_${project.name}',
                          child: Material(
                            type: MaterialType.transparency,
                            child: cardWidget,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard({
    required String name,
    required String imagePath,
    required double glow,
    required Offset lightPos,
  }) {
    return GlassCard(
      lightIntensity: glow,
      lightPosition: lightPos,
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ProjectImageWithBulb(imagePath: imagePath, mainGlow: glow),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: Color.lerp(
                  Colors.white.withValues(alpha: 0.85),
                  const Color(0xFFFFF3E0),
                  glow,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String subtitle, String title, double glow) {
    return Column(
      children: [
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
            color: Color.lerp(
              Colors.white.withValues(alpha: 0.25),
              const Color(0xFFFFD48A).withValues(alpha: 0.5),
              glow,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Color.lerp(
                  Colors.white.withValues(alpha: 0.8),
                  const Color(0xFFFFF8E1),
                  glow,
                )!,
                Color.lerp(
                  Colors.white.withValues(alpha: 0.5),
                  const Color(0xFFFFE0B2),
                  glow,
                )!,
              ],
            ).createShader(bounds),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LightConePainter extends CustomPainter {
  final double intensity;

  _LightConePainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity < 0.01) return;

    final centerX = size.width / 2;
    final topY = 160.0;
    final bottomY = size.height;

    final conePath = Path();
    final spread = size.width * 0.6;
    conePath.moveTo(centerX - 20, topY);
    conePath.lineTo(centerX - spread, bottomY);
    conePath.lineTo(centerX + spread, bottomY);
    conePath.lineTo(centerX + 20, topY);
    conePath.close();

    final coneGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromRGBO(255, 230, 160, intensity * 0.08),
        Color.fromRGBO(255, 220, 130, intensity * 0.04),
        Color.fromRGBO(255, 210, 100, intensity * 0.01),
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.5, 1.0],
    );

    final conePaint = Paint()
      ..shader = coneGradient.createShader(
        Rect.fromLTWH(0, topY, size.width, bottomY - topY),
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    canvas.drawPath(conePath, conePaint);

    final beamPath = Path();
    final beamSpread = size.width * 0.15;
    beamPath.moveTo(centerX - 8, topY);
    beamPath.lineTo(centerX - beamSpread, bottomY * 0.6);
    beamPath.lineTo(centerX + beamSpread, bottomY * 0.6);
    beamPath.lineTo(centerX + 8, topY);
    beamPath.close();

    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(255, 240, 190, intensity * 0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, topY, size.width, bottomY * 0.6 - topY))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawPath(beamPath, beamPaint);
  }

  @override
  bool shouldRepaint(covariant _LightConePainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}
