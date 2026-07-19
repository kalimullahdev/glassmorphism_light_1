import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glassmorphism_light/home_screen/new_code1.dart';
import 'package:glassmorphism_light/home_screen/new_code3.dart';
import 'package:glassmorphism_light/home_screen/new_code4.dart';
import 'package:glassmorphism_light/home_screen/new_code5.dart';
import 'light_bulb_painter.dart';
import 'glass_card.dart';
import 'floating_particles.dart';
import 'light_toggle_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isLightOn = false;
  late AnimationController _lightController;
  late AnimationController _flickerController;
  late Animation<double> _lightAnimation;
  late Animation<double> _flickerAnimation;

  // Background gradient animation
  late AnimationController _bgController;
  late Animation<double> _bgAnimation;

  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _glowNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();

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
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _bgAnimation = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeInOut,
    );

    _lightController.addListener(_updateGlow);
    _flickerController.addListener(_updateGlow);
  }

  void _updateGlow() {
    _glowNotifier.value = _lightAnimation.value * _flickerAnimation.value;
  }

  @override
  void dispose() {
    _lightController.dispose();
    _flickerController.dispose();
    _bgController.dispose();
    _scrollController.dispose();
    _glowNotifier.dispose();
    super.dispose();
  }

  void _toggleLight() {
    setState(() => _isLightOn = !_isLightOn);

    if (_isLightOn) {
      _lightController.forward();
      // Start flicker loop
      _startFlicker();
    } else {
      _lightController.reverse();
      _flickerController.stop();
    }
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
                        lightIntensity:
                            glow * 0.8, // Slightly less affected by attenuation
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
                        height: 3500, // Covers the length of the page
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
                    center: Alignment(0.0, -0.8 + bgShift * 0.1 - scrollShift),
                    radius: 1.8 + scrollShift * 0.2,
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
    final lightPos = const Offset(0.5, 0.0); // Light source at top center

    return Column(
      children: [
        const SizedBox(height: 200), // Space for bulb
        // === HERO SECTION ===
        Positioned.fill(
          child: ValueListenableBuilder<double>(
            valueListenable: _glowNotifier,
            builder: (context, glow, _) => buildGridContent5(glow, context),
          ),
        ),
        const SizedBox(height: 40),
        ValueListenableBuilder<double>(
          valueListenable: _glowNotifier,
          builder: (context, glow, _) =>
              _buildProjectsSection(_getAttenuatedGlow(glow, 0.0), lightPos),
        ),

        const SizedBox(height: 40),
        ValueListenableBuilder<double>(
          valueListenable: _glowNotifier,
          builder: (context, glow, _) =>
              _buildHeroSection(_getAttenuatedGlow(glow, 0.0), lightPos),
        ),

        const SizedBox(height: 40),

        // === FEATURES GRID ===
        ValueListenableBuilder<double>(
          valueListenable: _glowNotifier,
          builder: (context, glow, _) =>
              _buildFeaturesSection(_getAttenuatedGlow(glow, 0.2), lightPos),
        ),

        const SizedBox(height: 40),

        // === STATS BAR ===
        ValueListenableBuilder<double>(
          valueListenable: _glowNotifier,
          builder: (context, glow, _) =>
              _buildStatsSection(_getAttenuatedGlow(glow, 0.4), lightPos),
        ),

        const SizedBox(height: 40),

        // === SHOWCASE SECTION ===
        ValueListenableBuilder<double>(
          valueListenable: _glowNotifier,
          builder: (context, glow, _) =>
              _buildShowcaseSection(_getAttenuatedGlow(glow, 0.6), lightPos),
        ),

        const SizedBox(height: 40),

        // === TESTIMONIALS ===
        ValueListenableBuilder<double>(
          valueListenable: _glowNotifier,
          builder: (context, glow, _) => _buildTestimonialsSection(
            _getAttenuatedGlow(glow, 0.8),
            lightPos,
          ),
        ),

        const SizedBox(height: 40),

        // === PRICING SECTION ===
        ValueListenableBuilder<double>(
          valueListenable: _glowNotifier,
          builder: (context, glow, _) =>
              _buildPricingSection(_getAttenuatedGlow(glow, 0.9), lightPos),
        ),

        const SizedBox(height: 40),

        // === FOOTER ===
        ValueListenableBuilder<double>(
          valueListenable: _glowNotifier,
          builder: (context, glow, _) =>
              _buildFooter(_getAttenuatedGlow(glow, 1.0), lightPos),
        ),

        const SizedBox(height: 100),
      ],
    );
  }

  // ========================
  // HERO SECTION
  // ========================
  Widget _buildHeroSection(double glow, Offset lightPos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        lightIntensity: glow,
        lightPosition: lightPos,
        borderRadius: 32,
        glassThickness: 2.5,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 56),
        child: Column(
          children: [
            // Glowing accent line
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: glow > 0.1
                      ? [
                          const Color(0xFFFFD48A),
                          const Color(0xFFFFA726),
                          const Color(0xFFFFD48A),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.4),
                          Colors.white.withValues(alpha: 0.2),
                        ],
                ),
                boxShadow: glow > 0.1
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFFFFD48A,
                          ).withValues(alpha: glow * 0.5),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
            const SizedBox(height: 28),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Color.lerp(Colors.white70, const Color(0xFFFFF8E1), glow)!,
                  Color.lerp(Colors.white38, const Color(0xFFFFE0B2), glow)!,
                  Color.lerp(Colors.white70, const Color(0xFFFFF8E1), glow)!,
                ],
              ).createShader(bounds),
              child: const Text(
                'ILLUMINATED\nGLASSMORPHISM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Experience the art of light and glass — a futuristic interface where\nevery element responds to the glow of real illumination.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.7,
                color: Color.lerp(
                  Colors.white.withValues(alpha: 0.45),
                  const Color(0xFFFFE8C0).withValues(alpha: 0.75),
                  glow,
                ),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGlassButton('Explore', glow, isPrimary: true),
                const SizedBox(width: 16),
                _buildGlassButton('Learn More', glow),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassButton(String text, double glow, {bool isPrimary = false}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    Color.lerp(
                      Colors.white.withValues(alpha: 0.12),
                      const Color(0xFFFFD48A).withValues(alpha: 0.3),
                      glow,
                    )!,
                    Color.lerp(
                      Colors.white.withValues(alpha: 0.06),
                      const Color(0xFFFFA726).withValues(alpha: 0.15),
                      glow,
                    )!,
                  ],
                )
              : null,
          color: isPrimary ? null : Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: isPrimary
                ? Color.lerp(
                    Colors.white.withValues(alpha: 0.2),
                    const Color(0xFFFFD48A).withValues(alpha: 0.5),
                    glow,
                  )!
                : Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary
                ? Color.lerp(Colors.white70, const Color(0xFFFFE8C0), glow)
                : Colors.white.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // ========================
  // FEATURES SECTION
  // ========================
  Widget _buildFeaturesSection(double glow, Offset lightPos) {
    final features = [
      _FeatureData(
        Icons.auto_awesome_rounded,
        'Dynamic Lighting',
        'Realistic light simulation with real-time shadows and reflections across all UI elements.',
      ),
      _FeatureData(
        Icons.blur_on_rounded,
        'Premium Glass',
        'Multi-layered frosted glass with depth, refraction, and luminous edge highlights.',
      ),
      _FeatureData(
        Icons.animation_rounded,
        'Smooth Motion',
        'Buttery 60fps animations with physics-based easing and organic transitions.',
      ),
      _FeatureData(
        Icons.palette_rounded,
        'Adaptive Colors',
        'Colors that shift and warm as light fills the scene, creating an immersive atmosphere.',
      ),
      _FeatureData(
        Icons.grain_rounded,
        'Particle Effects',
        'Floating dust motes that catch the light and sparkle in the illuminated space.',
      ),
      _FeatureData(
        Icons.layers_rounded,
        'Depth Layers',
        'Multiple visual layers create a sense of real 3D space and physical presence.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSectionTitle('PROJECTS', 'Built with Precision', glow),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900
                  ? 3
                  : constraints.maxWidth > 550
                  ? 2
                  : 1;
              final cardWidth =
                  (constraints.maxWidth - 24 * (crossAxisCount + 1)) /
                  crossAxisCount;

              return Wrap(
                spacing: 0,
                runSpacing: 0,
                children: features.map((f) {
                  return SizedBox(
                    width: cardWidth + 40,
                    child: GlassCard(
                      lightIntensity: glow,
                      lightPosition: lightPos,
                      borderRadius: 20,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon with glass background
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(
                                    alpha: 0.1 + glow * 0.08,
                                  ),
                                  Colors.white.withValues(
                                    alpha: 0.03 + glow * 0.04,
                                  ),
                                ],
                              ),
                              border: Border.all(
                                color: Color.lerp(
                                  Colors.white.withValues(alpha: 0.08),
                                  const Color(
                                    0xFFFFD48A,
                                  ).withValues(alpha: 0.2),
                                  glow,
                                )!,
                                width: 1.2,
                              ),
                            ),
                            child: Icon(
                              f.icon,
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.5),
                                const Color(0xFFFFD48A),
                                glow,
                              ),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            f.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.8),
                                const Color(0xFFFFF3E0),
                                glow,
                              ),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            f.description,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.6,
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.35),
                                const Color(0xFFFFE8C0).withValues(alpha: 0.6),
                                glow,
                              ),
                            ),
                          ),
                        ],
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

  // ========================
  // Projects SECTION
  // ========================

  Widget _buildProjectsSection(double glow, Offset lightPos) {
    final testimonials = [
      _TestimonialData(
        'Sarah Chen',
        'Lead Designer',
        'The glassmorphism effects are absolutely stunning. It feels like interacting with real glass — the light reflections and shadows add an incredible sense of depth.',
      ),
      _TestimonialData(
        'Marcus Wright',
        'CTO, NexaLabs',
        'I\'ve never seen UI this beautiful. The way light dynamically affects every element creates an experience that feels truly alive and premium.',
      ),
      _TestimonialData(
        'Aisha Patel',
        'UX Architect',
        'This sets a new standard for web design. The attention to detail in the glass effects and lighting system is extraordinary. Pure art.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSectionTitle(
            'PROJECTS',
            'Turning complex ideas into beautiful experiences',
            glow,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 850
                  ? 3
                  : constraints.maxWidth > 550
                  ? 2
                  : 1;
              final cardWidth =
                  (constraints.maxWidth - 24 * (crossAxisCount + 1)) /
                  crossAxisCount;

              return Wrap(
                spacing: 0,
                runSpacing: 0,
                children: testimonials.map((t) {
                  return SizedBox(
                    width: cardWidth + 40,
                    child: GlassCard(
                      lightIntensity: glow,
                      lightPosition: lightPos,
                      borderRadius: 20,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quote icon
                          Icon(
                            Icons.format_quote_rounded,
                            color: Color.lerp(
                              Colors.white.withValues(alpha: 0.15),
                              const Color(0xFFFFD48A).withValues(alpha: 0.35),
                              glow,
                            ),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.quote,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.7,
                              fontStyle: FontStyle.italic,
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.45),
                                const Color(0xFFFFE8C0).withValues(alpha: 0.7),
                                glow,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(
                            color: Colors.white.withValues(
                              alpha: 0.05 + glow * 0.05,
                            ),
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.7),
                                const Color(0xFFFFF3E0),
                                glow,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.role,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.3),
                                const Color(0xFFFFD48A).withValues(alpha: 0.5),
                                glow,
                              ),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
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

  // ========================
  // STATS SECTION
  // ========================
  Widget _buildStatsSection(double glow, Offset lightPos) {
    final stats = [
      _StatData('99.9%', 'Uptime'),
      _StatData('50ms', 'Response'),
      _StatData('10M+', 'Users'),
      _StatData('4.9★', 'Rating'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        lightIntensity: glow,
        lightPosition: lightPos,
        borderRadius: 24,
        glassThickness: 2.0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats.asMap().entries.map((entry) {
                final i = entry.key;
                final s = entry.value;
                return Expanded(
                  child: Container(
                    decoration: i < stats.length - 1
                        ? BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.white.withValues(
                                  alpha: 0.06 + glow * 0.06,
                                ),
                                width: 1,
                              ),
                            ),
                          )
                        : null,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Color.lerp(
                                Colors.white,
                                const Color(0xFFFFD48A),
                                glow * 0.7,
                              )!,
                              Color.lerp(
                                Colors.white70,
                                const Color(0xFFFFA726),
                                glow * 0.7,
                              )!,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            s.value,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color.lerp(
                              Colors.white.withValues(alpha: 0.35),
                              const Color(0xFFFFE0B2).withValues(alpha: 0.6),
                              glow,
                            ),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  // ========================
  // SHOWCASE SECTION
  // ========================
  Widget _buildShowcaseSection(double glow, Offset lightPos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSectionTitle('SHOWCASE', 'Glass in Action', glow),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildShowcaseLarge(glow, lightPos),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildShowcaseSide(glow, lightPos),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _buildShowcaseLarge(glow, lightPos),
                  _buildShowcaseSide(glow, lightPos),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseLarge(double glow, Offset lightPos) {
    return GlassCard(
      lightIntensity: glow,
      lightPosition: lightPos,
      borderRadius: 24,
      glassThickness: 2.5,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated graph/visualization
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.03 + glow * 0.04),
                  Colors.white.withValues(alpha: 0.01),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05 + glow * 0.05),
              ),
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: _GraphPainter(glow: glow),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Performance Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color.lerp(
                Colors.white.withValues(alpha: 0.85),
                const Color(0xFFFFF3E0),
                glow,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time metrics visualization with smooth gradients and\nlight-responsive data points that glow under illumination.',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color.lerp(
                Colors.white.withValues(alpha: 0.35),
                const Color(0xFFFFE8C0).withValues(alpha: 0.6),
                glow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseSide(double glow, Offset lightPos) {
    return Column(
      children: [
        GlassCard(
          lightIntensity: glow,
          lightPosition: lightPos,
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Avatar glass circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF6366F1),
                        const Color(0xFFFFB74D),
                        glow * 0.5,
                      )!.withValues(alpha: 0.4),
                      Color.lerp(
                        const Color(0xFF8B5CF6),
                        const Color(0xFFFF9800),
                        glow * 0.5,
                      )!.withValues(alpha: 0.2),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1 + glow * 0.08),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white.withValues(alpha: 0.6 + glow * 0.2),
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Users',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color.lerp(
                          Colors.white.withValues(alpha: 0.7),
                          const Color(0xFFFFF3E0),
                          glow,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '2,847 online now',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.lerp(
                          Colors.white.withValues(alpha: 0.35),
                          const Color(0xFFFFD48A).withValues(alpha: 0.6),
                          glow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Glowing status dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(
                    const Color(0xFF4CAF50),
                    const Color(0xFFFFD48A),
                    glow * 0.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.lerp(
                        const Color(0xFF4CAF50),
                        const Color(0xFFFFD48A),
                        glow * 0.4,
                      )!.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          lightIntensity: glow,
          lightPosition: lightPos,
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Status',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color.lerp(
                    Colors.white.withValues(alpha: 0.7),
                    const Color(0xFFFFF3E0),
                    glow,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusRow('API Gateway', 0.98, glow),
              const SizedBox(height: 10),
              _buildStatusRow('Database', 0.95, glow),
              const SizedBox(height: 10),
              _buildStatusRow('CDN', 0.99, glow),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, double value, double glow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Color.lerp(
                  Colors.white.withValues(alpha: 0.4),
                  const Color(0xFFFFE8C0).withValues(alpha: 0.6),
                  glow,
                ),
              ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color.lerp(
                  Colors.white.withValues(alpha: 0.5),
                  const Color(0xFFFFD48A),
                  glow * 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 5,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.lerp(
                            const Color(0xFF4CAF50),
                            const Color(0xFFFFD48A),
                            glow * 0.4,
                          )!,
                          Color.lerp(
                            const Color(0xFF81C784),
                            const Color(0xFFFFA726),
                            glow * 0.4,
                          )!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(
                            const Color(0xFF4CAF50),
                            const Color(0xFFFFD48A),
                            glow * 0.4,
                          )!.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ========================
  // TESTIMONIALS SECTION
  // ========================
  Widget _buildTestimonialsSection(double glow, Offset lightPos) {
    final testimonials = [
      _TestimonialData(
        'Sarah Chen',
        'Lead Designer',
        'The glassmorphism effects are absolutely stunning. It feels like interacting with real glass — the light reflections and shadows add an incredible sense of depth.',
      ),
      _TestimonialData(
        'Marcus Wright',
        'CTO, NexaLabs',
        'I\'ve never seen UI this beautiful. The way light dynamically affects every element creates an experience that feels truly alive and premium.',
      ),
      _TestimonialData(
        'Aisha Patel',
        'UX Architect',
        'This sets a new standard for web design. The attention to detail in the glass effects and lighting system is extraordinary. Pure art.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSectionTitle('TESTIMONIALS', 'What People Say', glow),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 850
                  ? 3
                  : constraints.maxWidth > 550
                  ? 2
                  : 1;
              final cardWidth =
                  (constraints.maxWidth - 24 * (crossAxisCount + 1)) /
                  crossAxisCount;

              return Wrap(
                spacing: 0,
                runSpacing: 0,
                children: testimonials.map((t) {
                  return SizedBox(
                    width: cardWidth + 40,
                    child: GlassCard(
                      lightIntensity: glow,
                      lightPosition: lightPos,
                      borderRadius: 20,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quote icon
                          Icon(
                            Icons.format_quote_rounded,
                            color: Color.lerp(
                              Colors.white.withValues(alpha: 0.15),
                              const Color(0xFFFFD48A).withValues(alpha: 0.35),
                              glow,
                            ),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.quote,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.7,
                              fontStyle: FontStyle.italic,
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.45),
                                const Color(0xFFFFE8C0).withValues(alpha: 0.7),
                                glow,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Divider(
                            color: Colors.white.withValues(
                              alpha: 0.05 + glow * 0.05,
                            ),
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.7),
                                const Color(0xFFFFF3E0),
                                glow,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.role,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color.lerp(
                                Colors.white.withValues(alpha: 0.3),
                                const Color(0xFFFFD48A).withValues(alpha: 0.5),
                                glow,
                              ),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
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

  // ========================
  // PRICING SECTION
  // ========================
  Widget _buildPricingSection(double glow, Offset lightPos) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSectionTitle('PRICING', 'Choose Your Plan', glow),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 850
                  ? 3
                  : constraints.maxWidth > 550
                  ? 2
                  : 1;
              final cardWidth =
                  (constraints.maxWidth - 24 * (crossAxisCount + 1)) /
                  crossAxisCount;

              return Wrap(
                spacing: 0,
                runSpacing: 0,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: cardWidth + 40,
                    child: _buildPricingCard(
                      'Starter',
                      '\$9',
                      '/mo',
                      [
                        '5 Projects',
                        '10GB Storage',
                        'Basic Analytics',
                        'Email Support',
                      ],
                      false,
                      glow,
                      lightPos,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth + 40,
                    child: _buildPricingCard(
                      'Pro',
                      '\$29',
                      '/mo',
                      [
                        'Unlimited Projects',
                        '100GB Storage',
                        'Advanced Analytics',
                        'Priority Support',
                        'Custom Domain',
                      ],
                      true,
                      glow,
                      lightPos,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth + 40,
                    child: _buildPricingCard(
                      'Enterprise',
                      '\$99',
                      '/mo',
                      [
                        'Everything in Pro',
                        'Unlimited Storage',
                        'White Label',
                        'Dedicated Manager',
                        'SLA Guarantee',
                      ],
                      false,
                      glow,
                      lightPos,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    String title,
    String price,
    String period,
    List<String> features,
    bool isPopular,
    double glow,
    Offset lightPos,
  ) {
    return GlassCard(
      lightIntensity: glow,
      lightPosition: lightPos,
      borderRadius: 22,
      glassThickness: isPopular ? 2.5 : 2.0,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          if (isPopular)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(
                      const Color(0xFF6366F1).withValues(alpha: 0.4),
                      const Color(0xFFFFD48A).withValues(alpha: 0.4),
                      glow,
                    )!,
                    Color.lerp(
                      const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                      const Color(0xFFFFA726).withValues(alpha: 0.3),
                      glow,
                    )!,
                  ],
                ),
                border: Border.all(
                  color: Color.lerp(
                    const Color(0xFF6366F1).withValues(alpha: 0.3),
                    const Color(0xFFFFD48A).withValues(alpha: 0.4),
                    glow,
                  )!,
                ),
              ),
              child: Text(
                'MOST POPULAR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color.lerp(
                    Colors.white.withValues(alpha: 0.8),
                    const Color(0xFFFFF3E0),
                    glow,
                  ),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color.lerp(
                Colors.white.withValues(alpha: 0.7),
                const Color(0xFFFFF3E0),
                glow,
              ),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color.lerp(
                      Colors.white,
                      const Color(0xFFFFD48A),
                      glow * 0.6,
                    )!,
                    Color.lerp(
                      Colors.white70,
                      const Color(0xFFFFA726),
                      glow * 0.6,
                    )!,
                  ],
                ).createShader(bounds),
                child: Text(
                  price,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.05 + glow * 0.05)),
          const SizedBox(height: 16),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: Color.lerp(
                      Colors.white.withValues(alpha: 0.3),
                      const Color(0xFFFFD48A).withValues(alpha: 0.6),
                      glow,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.lerp(
                          Colors.white.withValues(alpha: 0.4),
                          const Color(0xFFFFE8C0).withValues(alpha: 0.6),
                          glow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isPopular
                  ? LinearGradient(
                      colors: [
                        Color.lerp(
                          Colors.white.withValues(alpha: 0.12),
                          const Color(0xFFFFD48A).withValues(alpha: 0.25),
                          glow,
                        )!,
                        Color.lerp(
                          Colors.white.withValues(alpha: 0.06),
                          const Color(0xFFFFA726).withValues(alpha: 0.12),
                          glow,
                        )!,
                      ],
                    )
                  : null,
              color: isPopular ? null : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: isPopular
                    ? Color.lerp(
                        Colors.white.withValues(alpha: 0.15),
                        const Color(0xFFFFD48A).withValues(alpha: 0.4),
                        glow,
                      )!
                    : Colors.white.withValues(alpha: 0.08),
                width: 1.2,
              ),
            ),
            child: Text(
              'Get Started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isPopular
                    ? Color.lerp(
                        Colors.white.withValues(alpha: 0.8),
                        const Color(0xFFFFF3E0),
                        glow,
                      )
                    : Colors.white.withValues(alpha: 0.4),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // FOOTER
  // ========================
  Widget _buildFooter(double glow, Offset lightPos) {
    return GlassCard(
      lightIntensity: glow,
      lightPosition: lightPos,
      borderRadius: 24,
      glassThickness: 1.5,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Color.lerp(
                  Colors.white.withValues(alpha: 0.4),
                  const Color(0xFFFFD48A),
                  glow,
                ),
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'GLASSMORPHISM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: Color.lerp(
                    Colors.white.withValues(alpha: 0.5),
                    const Color(0xFFFFF3E0).withValues(alpha: 0.8),
                    glow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Crafted with light, glass, and passion.',
            style: TextStyle(
              fontSize: 13,
              color: Color.lerp(
                Colors.white.withValues(alpha: 0.25),
                const Color(0xFFFFE8C0).withValues(alpha: 0.45),
                glow,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(
            color: Colors.white.withValues(alpha: 0.04 + glow * 0.04),
            height: 1,
          ),
          const SizedBox(height: 16),
          Text(
            '© 2026 Glassmorphism Light. All rights reserved.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.2),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // HELPERS
  // ========================
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

// ========================
// DATA CLASSES
// ========================
class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  _FeatureData(this.icon, this.title, this.description);
}

class _StatData {
  final String value;
  final String label;
  _StatData(this.value, this.label);
}

class _TestimonialData {
  final String name;
  final String role;
  final String quote;
  _TestimonialData(this.name, this.role, this.quote);
}

// ========================
// LIGHT CONE PAINTER
// ========================
class _LightConePainter extends CustomPainter {
  final double intensity;

  _LightConePainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity < 0.01) return;

    final centerX = size.width / 2;
    final topY = 160.0; // Below the bulb
    final bottomY = size.height;

    // Main cone
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

    // Central bright beam
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

// ========================
// GRAPH PAINTER (for showcase)
// ========================
class _GraphPainter extends CustomPainter {
  final double glow;

  _GraphPainter({required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03 + glow * 0.02)
      ..strokeWidth = 0.5;

    for (int i = 1; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data points
    final points = [0.7, 0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.6, 0.7, 0.85];
    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height * (1.0 - points[i]) * 0.8 + size.height * 0.1;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = size.width * (i - 1) / (points.length - 1);
        final prevY =
            size.height * (1.0 - points[i - 1]) * 0.8 + size.height * 0.1;
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Area fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(
            const Color(0xFF6366F1).withValues(alpha: 0.15),
            const Color(0xFFFFD48A).withValues(alpha: 0.15),
            glow,
          )!,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line
    paint.shader = LinearGradient(
      colors: [
        Color.lerp(
          const Color(0xFF6366F1),
          const Color(0xFFFFD48A),
          glow * 0.6,
        )!,
        Color.lerp(
          const Color(0xFF8B5CF6),
          const Color(0xFFFFA726),
          glow * 0.6,
        )!,
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Glow on the line
    if (glow > 0.1) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..shader = paint.shader
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4 + glow * 4);

      canvas.drawPath(path, glowPaint);
    }

    // Data dots
    for (int i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height * (1.0 - points[i]) * 0.8 + size.height * 0.1;

      final dotPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFF818CF8),
          const Color(0xFFFFD48A),
          glow * 0.6,
        )!;

      canvas.drawCircle(Offset(x, y), 3, dotPaint);

      if (glow > 0.1) {
        final dotGlow = Paint()
          ..color = Color.lerp(
            const Color(0xFF818CF8),
            const Color(0xFFFFD48A),
            glow * 0.6,
          )!.withValues(alpha: glow * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(Offset(x, y), 5, dotGlow);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.glow != glow;
  }
}
