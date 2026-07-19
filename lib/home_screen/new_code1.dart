import 'package:flutter/material.dart';
import 'package:glassmorphism_light/glass_card.dart';

Widget buildGridContent(double baseGlow, BuildContext context) {
  final lightPos = const Offset(0.5, 0.0);

  return Column(
    children: [
      // ROW 1
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: IntrinsicHeight(
          child: SizedBox(
            height: 320,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    _getAttenuatedGlow(baseGlow, 0.4),
                    lightPos,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: _buildHeroCard1(
                    _getAttenuatedGlow(baseGlow, 0.0),
                    lightPos,
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    _getAttenuatedGlow(baseGlow, 0.4),
                    lightPos,
                  ),
                ),

                // const SizedBox(width: 24),
                // Expanded(
                //   flex: 2,
                //   child: buildHeroCard(
                //     getAttenuatedGlow(baseGlow, 0.0),
                //     lightPos,
                //   ),
                // ),
                // const SizedBox(width: 24),
                // Expanded(
                //   flex: 1,
                //   child: buildProfileCard(
                //     getAttenuatedGlow(baseGlow, 0.4),
                //     lightPos,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),

      // Expanded(
      //   flex: 4,
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.stretch,
      //       children: [
      //         // Header
      //         Row(
      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //           children: [
      //             Text(
      //               'Projects',
      //               style: TextStyle(
      //                 fontSize: 24,
      //                 fontWeight: FontWeight.w700,
      //                 letterSpacing: 1.5,
      //                 color: Color.lerp(
      //                   Colors.white70,
      //                   const Color(0xFFFFF3E0),
      //                   baseGlow,
      //                 ),
      //               ),
      //             ),
      //             _buildGlassButton(
      //               'See all projects',
      //               baseGlow,
      //               isSmall: true,
      //             ),
      //           ],
      //         ),
      //         const SizedBox(height: 16),
      //         // Horizontal List
      //         Expanded(
      //           child: ListView.builder(
      //             scrollDirection: Axis.horizontal,
      //             physics: const BouncingScrollPhysics(),
      //             itemCount: 4,
      //             itemBuilder: (context, index) {
      //               return Container(
      //                 width: 340, // Wider for beautiful image cards
      //                 margin: EdgeInsets.only(right: index < 3 ? 24 : 0),
      //                 child: _buildProjectCard(
      //                   _getAttenuatedGlow(baseGlow, 0.8),
      //                   lightPos,
      //                   index,
      //                 ),
      //               );
      //             },
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      const SizedBox(height: 24),
    ],
  );
}

Widget _buildHeroCard1(double glow, Offset lightPos, {bool isMobile = false}) {
  return GlassCard(
    lightIntensity: glow,
    lightPosition: lightPos,
    borderRadius: 32,
    glassThickness: 2.5,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
    child: Center(
      child: Column(
        children: [
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
          ProfileHeader(isMobile: isMobile, glow: glow),
          // ProfileHeader is used instead of FittedBox
          // FittedBox(
          //   fit: BoxFit.scaleDown,
          //   child: Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       // Avatar on Left
          //       Container(
          //         width: isMobile ? 70 : 100,
          //         height: isMobile ? 70 : 100,
          //         decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           border: Border.all(
          //             color: Color.lerp(
          //               Colors.white.withValues(alpha: 0.2),
          //               const Color(0xFFFFD48A).withValues(alpha: 0.5),
          //               glow,
          //             )!,
          //             width: 2,
          //           ),
          //           image: const DecorationImage(
          //             image: AssetImage("assets/kalimullah_main.jpg"),
          //             fit: BoxFit.cover,
          //           ),
          //           boxShadow: glow > 0.1
          //               ? [
          //                   BoxShadow(
          //                     color: const Color(
          //                       0xFFFFD48A,
          //                     ).withValues(alpha: glow * 0.4),
          //                     blurRadius: 20,
          //                   ),
          //                 ]
          //               : [],
          //         ),
          //       ),
          //       SizedBox(width: isMobile ? 16 : 24),

          //       // Content on Right
          //       Column(
          //         mainAxisSize: MainAxisSize.min,
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           ShaderMask(
          //             shaderCallback: (bounds) => LinearGradient(
          //               colors: [
          //                 Color.lerp(
          //                   Colors.white70,
          //                   const Color(0xFFFFF8E1),
          //                   glow,
          //                 )!,
          //                 Color.lerp(
          //                   Colors.white38,
          //                   const Color(0xFFFFE0B2),
          //                   glow,
          //                 )!,
          //                 Color.lerp(
          //                   Colors.white70,
          //                   const Color(0xFFFFF8E1),
          //                   glow,
          //                 )!,
          //               ],
          //             ).createShader(bounds),
          //             child: Text(
          //               'FlutterFlow, Flutter, AI, Supabase, Firebase ',
          //               style: TextStyle(
          //                 fontSize: isMobile ? 22 : 26,
          //                 fontWeight: FontWeight.w800,
          //                 color: Colors.white,
          //                 letterSpacing: 1,
          //               ),
          //             ),
          //           ),
          //           const SizedBox(height: 8),
          //           SizedBox(
          //             child: Text(
          //               'I build innovative, high-performance mobile and web applications powered by deep expertise in FlutterFlow, Flutter, and Dart. This foundation lets me solve complex development challenges with clean, reliable, production-ready results.',
          //               style: TextStyle(
          //                 fontSize: 12,
          //                 height: 1.5,
          //                 color: Color.lerp(
          //                   Colors.white38,
          //                   const Color(0xFFFFE8C0).withValues(alpha: 0.75),
          //                   glow,
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    ),
  );
}

Widget _buildStatCard(double glow, Offset lightPos) {
  return GlassCard(
    lightIntensity: glow,
    lightPosition: lightPos,
    borderRadius: 24,
    width: 500,
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.auto_awesome_rounded,
          color: Color.lerp(Colors.white30, const Color(0xFFFFD48A), glow),
          size: 32,
        ),
        // const Spacer(),
        Text(
          'Luminous',
          style: TextStyle(
            fontSize: 14,
            color: Color.lerp(
              Colors.white38,
              const Color(0xFFFFE0B2).withValues(alpha: 0.6),
              glow,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Color.lerp(Colors.white, const Color(0xFFFFD48A), glow * 0.7)!,
              Color.lerp(Colors.white70, const Color(0xFFFFA726), glow * 0.7)!,
            ],
          ).createShader(bounds),
          child: const Text(
            '99.9%',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
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

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.isMobile, required this.glow});

  final bool isMobile;
  final double glow; // 0.0 - 1.0

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar on Left
          Container(
            width: isMobile ? 70 : 100,
            height: isMobile ? 70 : 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color.lerp(
                  Colors.white.withValues(alpha: 0.2),
                  const Color(0xFFFFD48A).withValues(alpha: 0.5),
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
                        color: const Color(
                          0xFFFFD48A,
                        ).withValues(alpha: glow * 0.4),
                        blurRadius: 20,
                      ),
                    ]
                  : [],
            ),
          ),
          SizedBox(width: isMobile ? 16 : 24),

          // Content on Right — Expanded gives this a bounded width so text can wrap
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Color.lerp(
                        Colors.white70,
                        const Color(0xFFFFF8E1),
                        glow,
                      )!,
                      Color.lerp(
                        Colors.white38,
                        const Color(0xFFFFE0B2),
                        glow,
                      )!,
                      Color.lerp(
                        Colors.white70,
                        const Color(0xFFFFF8E1),
                        glow,
                      )!,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'FlutterFlow, Flutter, AI, Supabase, Firebase',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'I build innovative, high-performance mobile and web applications '
                  'powered by deep expertise in FlutterFlow, Flutter, and Dart. This '
                  'foundation lets me solve complex development challenges with '
                  'clean, reliable, production-ready results.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Color.lerp(
                      Colors.white38,
                      const Color(0xFFFFE8C0).withValues(alpha: 0.75),
                      glow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildHeroCard(double glow, Offset lightPos) {
  return GlassCard(
    lightIntensity: glow,
    lightPosition: lightPos,
    borderRadius: 32,
    glassThickness: 2.5,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
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
                    : [Colors.white24, Colors.white38, Colors.white24],
              ),
              boxShadow: glow > 0.1
                  ? [
                      BoxShadow(
                        color: const Color(
                          0xFFFFD48A,
                        ).withValues(alpha: glow * 0.5),
                        blurRadius: 12,
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Color.lerp(Colors.white70, const Color(0xFFFFF8E1), glow)!,
                Color.lerp(Colors.white38, const Color(0xFFFFE0B2), glow)!,
                Color.lerp(Colors.white70, const Color(0xFFFFF8E1), glow)!,
              ],
            ).createShader(bounds),
            child: const Text(
              'GLASSMORPHISM',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A futuristic interface where every element responds\nto the glow of real physical illumination.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color.lerp(
                Colors.white38,
                const Color(0xFFFFE8C0).withValues(alpha: 0.75),
                glow,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildGlassButton(
  String text,
  double glow, {
  bool isPrimary = false,
  bool isSmall = false,
}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : 32,
        vertical: isSmall ? 8 : 14,
      ),
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
              : Colors.white.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
          fontSize: isSmall ? 12 : 14,
          letterSpacing: 1,
        ),
      ),
    ),
  );
}

Widget _buildProjectCard(double glow, Offset lightPos, int index) {
  final titles = [
    'Nexa Dashboard',
    'Lumiere App',
    'Aura Design System',
    'Nova Analytics',
  ];
  final images = [
    'https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1618761714954-0b8cd0026356?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1507238692062-5a042e9e18c6?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1558655146-d09347e92766?auto=format&fit=crop&w=400&q=80',
  ];

  return GlassCard(
    lightIntensity: glow,
    lightPosition: lightPos,
    borderRadius: 24,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image Above
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1 + glow * 0.1),
                width: 1,
              ),
              image: DecorationImage(
                image: NetworkImage(images[index % 4]),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(
                    alpha: 0.3 - glow * 0.2,
                  ), // Darkens slightly when light is off
                  BlendMode.darken,
                ),
              ),
              boxShadow: glow > 0.2
                  ? [
                      BoxShadow(
                        color: const Color(
                          0xFFFFD48A,
                        ).withValues(alpha: glow * 0.15),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Name Below
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            titles[index % 4],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color.lerp(Colors.white70, const Color(0xFFFFF3E0), glow),
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 4),
      ],
    ),
  );
}
