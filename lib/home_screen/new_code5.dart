import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:glassmorphism_light/home_screen/glass_card.dart';
import 'package:glassmorphism_light/home_screen/light_bulb_painter.dart';
import 'package:glassmorphism_light/home_screen/detail_page.dart';

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
          horizontal: device == DeviceType.mobile ? 16.0 : 24.0,
          vertical: 16.0,
        ),
        child: _buildResponsiveCards(baseGlow, device, context),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout Builder
// ─────────────────────────────────────────────────────────────────────────────
Widget _buildResponsiveCards(double baseGlow, DeviceType device, BuildContext context) {
  final isMobile = device == DeviceType.mobile;

  final heroCardWidget = _buildHeroCard(
    _getAttenuatedGlow(baseGlow, 0.0),
    isMobile: isMobile,
  );

  final hero = MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => DetailPage(
              heroTag: 'hero_profile',
              child: heroCardWidget,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'hero_profile',
        child: Material(
          type: MaterialType.transparency,
          child: heroCardWidget,
        ),
      ),
    ),
  );

  final statLeftWidget = _buildStatCard(
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
        (title: 'Start to Matric', date: '2003-2015'),
        (title: 'FSc', date: '2015-2017'),
        (title: 'BSSE', date: '2017-2021'),
      ],
    ),
  );

  final statLeft = MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => DetailPage(
              heroTag: 'hero_education',
              child: statLeftWidget,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'hero_education',
        child: Material(
          type: MaterialType.transparency,
          child: statLeftWidget,
        ),
      ),
    ),
  );

  final statRightWidget = _buildStatCard(
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

  final statRight = MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (_, __, ___) => DetailPage(
              heroTag: 'hero_work',
              child: statRightWidget,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'hero_work',
        child: Material(
          type: MaterialType.transparency,
          child: statRightWidget,
        ),
      ),
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
            Expanded(flex: 10, child: hero),
            Expanded(flex: 7, child: statRight),
          ],
        ),
      );

    case DeviceType.tablet:
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          hero,
          const SizedBox(height: 8), // Decreased gap
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: statLeft),
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
    return AvatarWithBulb(size: size, mainGlow: glow);
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

class AvatarWithBulb extends StatefulWidget {
  final double size;
  final double mainGlow;

  const AvatarWithBulb({super.key, required this.size, required this.mainGlow});

  @override
  State<AvatarWithBulb> createState() => _AvatarWithBulbState();
}

class _AvatarWithBulbState extends State<AvatarWithBulb>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
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
              final pulse = _pulseController.value;
              final effectiveGlow = glowValue * (0.93 + pulse * 0.07);

              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.lerp(
                        Colors.white.withValues(alpha: 0.2),
                        _accent.withValues(alpha: 0.5),
                        effectiveGlow,
                      )!,
                      width: 2,
                    ),
                    boxShadow: effectiveGlow > 0.1
                        ? [
                            BoxShadow(
                              color: _accent.withValues(
                                alpha: effectiveGlow * 0.4,
                              ),
                              blurRadius: 20,
                            ),
                          ]
                        : const [],
                  ),
                  child: ClipOval(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // A. The Profile Image
                        Image.asset(
                          "assets/kalimullah_main.jpg",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.black.withValues(alpha: 0.2),
                              child: const Center(
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.white24,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),

                        // B. Dark Room Overlay
                        IgnorePointer(
                          child: Container(
                            color: Colors.black.withValues(
                              alpha:
                                  (1.0 - effectiveGlow).clamp(0.0, 1.0) * 0.78,
                            ),
                          ),
                        ),

                        // C. Light Cone & Hotspot Overlays
                        if (effectiveGlow > 0.01) ...[
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

                        // D. Premium Glass Reflections / Highlights
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

                        // E. Subtle Inner border
                        IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 1.2,
                                color: Color.lerp(
                                  Colors.white.withValues(alpha: 0.08),
                                  const Color(
                                    0xFFFFD54F,
                                  ).withValues(alpha: 0.22),
                                  effectiveGlow,
                                )!,
                              ),
                            ),
                          ),
                        ),

                        // 2. Hanging Light Bulb (Moved INSIDE ClipOval with top: 0 to connect to border perfectly)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Center(
                              child: SizedBox(
                                width: 32,
                                height:
                                    26, // Reduced height to shorten the wire
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
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
