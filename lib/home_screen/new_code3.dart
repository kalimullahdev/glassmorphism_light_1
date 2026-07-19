import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism_light/glass_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Responsive breakpoints
// ─────────────────────────────────────────────────────────────────────────────
enum DeviceType { mobile, tablet, desktop }

DeviceType _deviceTypeFor(double width) {
  if (width < 600) return DeviceType.mobile;
  if (width < 1024) return DeviceType.tablet;
  return DeviceType.desktop;
}

// Shared design constants
const Offset _lightPos = Offset(0.5, 0.0);
const Color _accent = Color(0xFFFFD48A);
const Color _accentDeep = Color(0xFFFFA726);
const double _maxContentWidth = 1400;

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — drop-in replacement, same signature as before.
// ─────────────────────────────────────────────────────────────────────────────
Widget buildGridContent3(double baseGlow, BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final device = _deviceTypeFor(constraints.maxWidth);
      final hPad = device == DeviceType.mobile ? 16.0 : 24.0;

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildResponsiveCards(baseGlow, device),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout: adapts the same three cards across mobile / tablet / desktop.
//
//  desktop  →  [ stat ][ hero (2x) ][ stat ]      all one row, equal height
//  tablet   →  [ hero (full width) ]              hero on top,
//              [ stat ][ stat ]                    two stats below
//  mobile   →  [ hero (full width) ]              everything stacked,
//              [ stat ][ stat ]                    stats share one row
// ─────────────────────────────────────────────────────────────────────────────
Widget _buildResponsiveCards(double baseGlow, DeviceType device) {
  final isMobile = device == DeviceType.mobile;

  final hero = _buildHeroCard(
    _getAttenuatedGlow(baseGlow, 0.0),
    isMobile: isMobile,
  );

  final statLeft = _buildStatCard(
    _getAttenuatedGlow(baseGlow, 0.4),
    icon: FaIcon(
      FontAwesomeIcons.bookOpen,
      color: Color.lerp(
        Colors.white70,
        _accent,
        _getAttenuatedGlow(baseGlow, 0.4),
      ),
      size: isMobile ? 21 : 25,
    ),
    label: 'Education',
    compact: isMobile,
    details: LeftDetailsWidget(glow: baseGlow),
  );

  final statRight = _buildStatCard(
    _getAttenuatedGlow(baseGlow, 0.4),
    icon: FaIcon(
      FontAwesomeIcons.gamepad,
      color: Color.lerp(
        Colors.white30,
        _accent,
        _getAttenuatedGlow(baseGlow, 0.4),
      ),
      size: isMobile ? 28 : 32,
    ),
    label: 'Work\nExperience',
    compact: isMobile,
    details: RightDetailsWidget(glow: baseGlow),
  );

  // Two stat cards side by side, matched to the taller one.
  Widget statRow(double gap) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: statLeft),
        SizedBox(width: gap),
        Expanded(child: statRight),
      ],
    ),
  );

  switch (device) {
    case DeviceType.desktop:
      // Single row. IntrinsicHeight + stretch makes the stat cards grow to
      // match the naturally-taller hero card, so tops and bottoms align.
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: statLeft),
            const SizedBox(width: 24),
            Expanded(flex: 2, child: hero),
            const SizedBox(width: 24),
            Expanded(child: statRight),
          ],
        ),
      );

    case DeviceType.tablet:
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [hero, const SizedBox(height: 20), statRow(20)],
      );

    case DeviceType.mobile:
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [hero, const SizedBox(height: 16), statRow(16)],
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero card
// ─────────────────────────────────────────────────────────────────────────────
Widget _buildHeroCard(double glow, {required bool isMobile}) {
  return GlassCard(
    lightIntensity: glow,
    lightPosition: _lightPos,
    borderRadius: 32,
    glassThickness: 2.5,
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 20 : 24,
      vertical: isMobile ? 32 : 40,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _AccentBar(glow: glow),
        SizedBox(height: isMobile ? 24 : 28),
        ProfileHeader(isMobile: isMobile, glow: glow),
      ],
    ),
  );
}

/// The small glowing gradient bar above the profile.
class _AccentBar extends StatelessWidget {
  const _AccentBar({required this.glow});
  final double glow;

  @override
  Widget build(BuildContext context) {
    final lit = glow > 0.1;
    return Container(
      width: 60,
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          colors: lit
              ? const [_accent, _accentDeep, _accent]
              : [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.2),
                ],
        ),
        boxShadow: lit
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: glow * 0.5),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : const [],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stat card
// ─────────────────────────────────────────────────────────────────────────────
Widget _buildStatCard(
  double glow, {
  required Icon icon,
  required String label,
  required Widget details,
  bool compact = false,
}) {
  return GlassCard(
    lightIntensity: glow,
    lightPosition: _lightPos,
    borderRadius: 24,
    padding: EdgeInsets.all(compact ? 18 : 24),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 0,
        vertical: 20,
      ), // FYI: Also need to fix it. Getting layout issue
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Color.lerp(Colors.white, _accent, glow * 0.7)!,
                      Color.lerp(Colors.white70, _accentDeep, glow * 0.7)!,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: compact ? 20 : 25,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Spacer(),
              icon,
            ],
          ),
          SizedBox(height: compact ? 12 : 16),
          details,
        ],
      ),
    ),
  );
}

class LeftDetailsWidget extends StatelessWidget {
  const LeftDetailsWidget({super.key, required this.glow});

  final double glow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatsSubText(glow: glow, firstText: "Matric", timePeriod: "2002-2014"),
        const SizedBox(height: 8),
        StatsSubText(glow: glow, firstText: "FSc", timePeriod: "2015-2016"),
        const SizedBox(height: 8),
        StatsSubText(glow: glow, firstText: "BSSE", timePeriod: "2017-2021"),
        const SizedBox(height: 8),
      ],
    );
  }
}

class RightDetailsWidget extends StatelessWidget {
  const RightDetailsWidget({super.key, required this.glow});

  final double glow;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StatsSubText(
          glow: glow,
          firstText: "Internship",
          timePeriod: "September,2021 - March,2022",
        ),
        const SizedBox(height: 8),
        StatsSubText(
          glow: glow,
          firstText: "Fiverr",
          timePeriod: "March,2022 - July,2024",
        ),
        const SizedBox(height: 8),
        StatsSubText(
          glow: glow,
          firstText: "Upwork",
          timePeriod: "March,2024 - Present",
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class StatsSubText extends StatelessWidget {
  const StatsSubText({
    super.key,
    required this.glow,
    required this.firstText,
    required this.timePeriod,
  });

  final double glow;
  final String firstText;
  final String timePeriod;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          firstText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Color.lerp(
              Colors.white38,
              const Color(0xFFFFE0B2).withValues(alpha: 0.6),
              glow,
            ),
          ),
        ),
        Spacer(),
        Text(
          timePeriod,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Color.lerp(
              Colors.white38,
              const Color(0xFFFFE0B2).withValues(alpha: 0.6),
              glow,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glow helper
// ─────────────────────────────────────────────────────────────────────────────
double _getAttenuatedGlow(double baseGlow, double depth) {
  return baseGlow * (1.0 - depth * 0.8).clamp(0.0, 1.0);
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile header — horizontal on tablet/desktop, centered stack on mobile.
// ─────────────────────────────────────────────────────────────────────────────
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.isMobile, required this.glow});

  final bool isMobile;
  final double glow; // 0.0 – 1.0

  static const String _headline = 'Kalim ullah (Software Engineer)';
  static const String _body =
      'I build innovative, high-performance mobile and web applications powered '
      'by deep expertise in FlutterFlow, Flutter, and Dart. This foundation lets '
      'me solve complex development challenges with clean, reliable, '
      'production-ready results.';

  @override
  Widget build(BuildContext context) {
    return isMobile ? _buildVertical() : _buildHorizontal();
  }

  // Tablet / desktop: avatar left, text right (text wraps within Expanded).
  Widget _buildHorizontal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(100),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headingText(26, TextAlign.start),
                const SizedBox(height: 8),
                _bodyText(TextAlign.start),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mobile: avatar centered on top, text centered below — reads cleanly on
  // narrow screens instead of squeezing a two-column row.
  Widget _buildVertical() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _avatar(88),
        const SizedBox(height: 20),
        _headingText(22, TextAlign.center),
        const SizedBox(height: 10),
        _bodyText(TextAlign.center),
      ],
    );
  }

  Widget _avatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color.lerp(
            Colors.white.withValues(alpha: 0.2),
            _accent.withValues(alpha: 0.5),
            glow,
          )!,
          width: 2,
        ),
        image: const DecorationImage(
          image: AssetImage("assets/kalimullah_main.jpg"),
          fit: BoxFit.cover,
        ),
        boxShadow: glow > 0.1
            ? [
                BoxShadow(
                  color: _accent.withValues(alpha: glow * 0.4),
                  blurRadius: 20,
                ),
              ]
            : const [],
      ),
    );
  }

  Widget _headingText(double fontSize, TextAlign align) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Color.lerp(Colors.white70, const Color(0xFFFFF8E1), glow)!,
          Color.lerp(Colors.white38, const Color(0xFFFFE0B2), glow)!,
          Color.lerp(Colors.white70, const Color(0xFFFFF8E1), glow)!,
        ],
      ).createShader(bounds),
      child: Text(
        _headline,
        textAlign: align,
        style: const TextStyle(
          fontSize: 26, // overridden below via copyWith for clarity
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1,
          height: 1.2,
        ).copyWith(fontSize: fontSize),
      ),
    );
  }

  Widget _bodyText(TextAlign align) {
    return Text(
      _body,
      textAlign: align,
      style: TextStyle(
        fontSize: 12,
        height: 1.5,
        color: Color.lerp(
          Colors.white38,
          const Color(0xFFFFE8C0).withValues(alpha: 0.75),
          glow,
        ),
      ),
    );
  }
}
