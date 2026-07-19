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

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────
Widget buildGridContent(double baseGlow, BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final device = _deviceTypeFor(constraints.maxWidth);

      // FIX: Removed Center and ConstrainedBox(1400) limits.
      // The row will now take the full available width, aligning perfectly
      // with the wide "ILLUMINATED GLASSMORPHISM" widget below it.
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: device == DeviceType.mobile ? 16.0 : 0.0,
          vertical: 16.0,
        ),
        child: _buildResponsiveCards(baseGlow, device),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout Builder
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
    details: _StatList(
      glow: baseGlow,
      items: const [
        (title: 'Start to Matric', date: '2002-2014'),
        (title: 'FSc', date: '2015-2016'),
        (title: 'BSSE', date: '2017-2021'),
      ],
    ),
  );

  final statRight = _buildStatCard(
    _getAttenuatedGlow(baseGlow, 0.4),
    icon: Icon(
      Icons.work,
      color: Color.lerp(
        Colors.white30,
        _accent,
        _getAttenuatedGlow(baseGlow, 0.4),
      ),
      size: isMobile ? 28 : 32,
    ),
    label: 'Work Experience',
    compact: isMobile,
    details: _StatList(
      glow: baseGlow,
      items: const [
        (title: 'Internship (Flutter)', date: 'Sep 2021 - Mar 2022'),
        (title: 'Fiverr (Flutter)', date: 'Mar 2022 - Jul 2024'),
        (title: 'Upwork (FlutterFlow)', date: 'Mar 2024 - Present'),
      ],
    ),
  );

  switch (device) {
    case DeviceType.desktop:
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FIX: Updated ratio to 7:10:7 giving side cards more space for text
            Expanded(flex: 7, child: statLeft),
            const SizedBox(width: 16), // FIX: Decreased gap distance
            Expanded(flex: 10, child: hero),
            const SizedBox(width: 16), // FIX: Decreased gap distance
            Expanded(flex: 7, child: statRight),
          ],
        ),
      );

    case DeviceType.tablet:
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          hero,
          const SizedBox(height: 16), // Decreased gap
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: statLeft),
                const SizedBox(width: 16), // Decreased gap
                Expanded(child: statRight),
              ],
            ),
          ),
        ],
      );

    case DeviceType.mobile:
      return Column(
        mainAxisSize: MainAxisSize.min,
        // FIX: Mobile should stack everything vertically so each card has maximum width
        children: [
          hero,
          const SizedBox(height: 16),
          statLeft,
          const SizedBox(height: 16),
          statRight,
        ],
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
      horizontal: isMobile ? 20 : 32,
      vertical: isMobile ? 32 : 40,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _AccentBar(glow: glow),
        SizedBox(height: isMobile ? 24 : 28),
        ProfileHeader(isMobile: isMobile, glow: glow),
      ],
    ),
  );
}

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
// Stat card & Details
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
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 20 : 28,
      vertical: compact ? 28 : 36,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: compact ? 18 : 24),

        Row(
          children: [
            Expanded(
              child: FittedBox(
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
            ),
            const SizedBox(width: 16),
            icon,
          ],
        ),
        SizedBox(height: compact ? 18 : 24),
        details,
      ],
    ),
  );
}

/// FIX: Consolidated duplicate classes into one clean generic list builder using Dart 3 records
class _StatList extends StatelessWidget {
  const _StatList({required this.glow, required this.items});

  final double glow;
  final List<({String title, String date})> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          StatsSubText(
            glow: glow,
            firstText: items[i].title,
            timePeriod: items[i].date,
          ),
          if (i < items.length - 1) const SizedBox(height: 12),
        ],
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // FIX: CrossAxisAlignment.start ensures texts align cleanly to the top if the dates wrap
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            firstText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color.lerp(
                Colors.white38,
                const Color(0xFFFFE0B2).withValues(alpha: 0.6),
                glow,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3, // Gives dates slightly more width priority
          child: Text(
            timePeriod,
            textAlign: TextAlign.right,
            // FIX: Removed maxLines and ellipsis so that if the screen gets tight,
            // the text will automatically wrap to a second line and remain fully visible!
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.3, // cleaner line spacing for wrapped text
              color: Color.lerp(
                Colors.white38,
                const Color(0xFFFFE0B2).withValues(alpha: 0.6),
                glow,
              ),
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
  final double glow;

  static const String _headline = 'Kalim ullah (Software Engineer)';
  static const String _body =
      'I build innovative, high-performance mobile and web applications powered '
      'by deep expertise in FlutterFlow, Flutter, Dart, Firebase, Supabase, Rest API, AI and Payment Integration. This foundation lets '
      'me solve complex development challenges with clean, reliable, '
      'production-ready results.';

  @override
  Widget build(BuildContext context) {
    return isMobile ? _buildVertical() : _buildHorizontal();
  }

  Widget _buildHorizontal() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(100),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headingText(24, TextAlign.start),
                const SizedBox(height: 8),
                _bodyText(TextAlign.start),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          fontSize: 26,
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
