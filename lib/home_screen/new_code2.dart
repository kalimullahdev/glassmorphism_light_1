import 'package:flutter/material.dart';
import 'package:glassmorphism_light/glass_card.dart';
import 'package:glassmorphism_light/home_screen/new_code1.dart';

/// Below this width the layout stacks for phones; at or above it the
/// stat • hero • stat row is used.
const double _mobileBreakpoint = 600;

/// Content never grows wider than this on very large screens, so the
/// cards stay readable instead of stretching edge-to-edge.
const double _maxContentWidth = 1400;

Widget buildGridContentNT(double baseGlow, BuildContext context) {
  const lightPos = Offset(0.5, 0.0);

  // LayoutBuilder reacts to the space this widget is actually given
  // (works even inside a sidebar or split view), not just the raw screen.
  return LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isMobile = width < _mobileBreakpoint;
      final horizontalPadding = isMobile ? 16.0 : 24.0;

      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 12,
                ),
                child: isMobile
                    ? _buildMobileLayout(baseGlow, lightPos)
                    : _buildWideLayout(
                        baseGlow,
                        lightPos,
                        availableWidth: width,
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    },
  );
}

/// Tablet / desktop: stat • hero • stat in a single equal-height row.
///
/// `IntrinsicHeight` + `CrossAxisAlignment.stretch` makes every card match
/// the tallest one (the hero), so height is driven by content instead of a
/// hard-coded 320.
Widget _buildWideLayout(
  double baseGlow,
  Offset lightPos, {
  required double availableWidth,
}) {
  final gap = availableWidth < 1000 ? 16.0 : 24.0;

  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _buildStatCard(_getAttenuatedGlow(baseGlow, 0.4), lightPos),
        ),
        SizedBox(width: gap),
        Expanded(
          flex: 2,
          child: _buildHeroCard1(_getAttenuatedGlow(baseGlow, 0.0), lightPos),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _buildStatCard(_getAttenuatedGlow(baseGlow, 0.4), lightPos),
        ),
      ],
    ),
  );
}

/// Phone: hero on top, the two stat cards side-by-side beneath it.
Widget _buildMobileLayout(double baseGlow, Offset lightPos) {
  return Column(
    children: [
      _buildHeroCard1(
        _getAttenuatedGlow(baseGlow, 0.0),
        lightPos,
        isMobile: true,
      ),
      const SizedBox(height: 16),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildStatCard(
                _getAttenuatedGlow(baseGlow, 0.4),
                lightPos,
                isMobile: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                _getAttenuatedGlow(baseGlow, 0.4),
                lightPos,
                isMobile: true,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildHeroCard1(double glow, Offset lightPos, {bool isMobile = false}) {
  return GlassCard(
    lightIntensity: glow,
    lightPosition: lightPos,
    borderRadius: 32,
    glassThickness: 2.5,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: isMobile ? 32 : 40),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accent divider
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: glow > 0.1
                    ? const [
                        Color(0xFFFFD48A),
                        Color(0xFFFFA726),
                        Color(0xFFFFD48A),
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
                  : const [],
            ),
          ),
          SizedBox(height: isMobile ? 20 : 28),
          ProfileHeader(isMobile: isMobile, glow: glow),
        ],
      ),
    ),
  );
}

Widget _buildStatCard(double glow, Offset lightPos, {bool isMobile = false}) {
  return GlassCard(
    lightIntensity: glow,
    lightPosition: lightPos,
    borderRadius: 24,
    // No fixed width: the parent Expanded controls sizing.
    padding: EdgeInsets.all(isMobile ? 20 : 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          color: Color.lerp(Colors.white30, const Color(0xFFFFD48A), glow),
          size: isMobile ? 28 : 32,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Text(
          'Luminous',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            color: Color.lerp(
              Colors.white38,
              const Color(0xFFFFE0B2).withValues(alpha: 0.6),
              glow,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // FittedBox guarantees the big number never overflows a narrow card.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Color.lerp(Colors.white, const Color(0xFFFFD48A), glow * 0.7)!,
                Color.lerp(
                  Colors.white70,
                  const Color(0xFFFFA726),
                  glow * 0.7,
                )!,
              ],
            ).createShader(bounds),
            child: Text(
              '99.9%',
              style: TextStyle(
                fontSize: isMobile ? 30 : 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

double _getAttenuatedGlow(double baseGlow, double depth) {
  return baseGlow * (1.0 - depth * 0.8).clamp(0.0, 1.0);
}
