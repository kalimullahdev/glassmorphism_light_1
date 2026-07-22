import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'dart:ui' as ui;
import 'shared_state.dart';

class DetailPage extends StatefulWidget {
  final String heroTag;
  final Widget? child;
  final String htmlAssetPath;

  const DetailPage({
    super.key,
    required this.heroTag,
    this.child,
    this.htmlAssetPath = 'assets/record_of_education.html',
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _lightAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // 1200ms cinematic transition as requested
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Set initial light state based on shared global state
    _animationController.value = globalLightStateNotifier.value ? 1.0 : 0.0;

    // Listen for global state changes (e.g. from toggle)
    globalLightStateNotifier.addListener(_onGlobalLightStateChanged);

    _lightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    );

    _controller = WebViewController();

    if (!kIsWeb) {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFF5F2E9))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              // Let the webview try to handle the PDF download natively
              return NavigationDecision.navigate;
            },
          ),
        );
    } else {
      // On web, NavigationDelegate is not fully supported, so we stop loading immediately
      // or delay slightly to allow iframe render.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    }

    _loadHtmlFromAssets();
  }

  Future<void> _loadHtmlFromAssets() async {
    if (kIsWeb) {
      // On Flutter Web, loading local HTML files directly by URL can fail due to asset serving path issues.
      // We load the string from rootBundle and pass it directly to the WebView.
      try {
        final String htmlContent = await rootBundle.loadString(
          widget.htmlAssetPath,
        );
        await _controller.loadHtmlString(htmlContent);
      } catch (e) {
        debugPrint('Error loading HTML: $e');
      }
    } else {
      // On mobile, we use loadFlutterAsset
      await _controller.loadFlutterAsset(widget.htmlAssetPath);
    }
  }

  void _onGlobalLightStateChanged() {
    if (globalLightStateNotifier.value) {
      if (_animationController.status != AnimationStatus.forward &&
          _animationController.status != AnimationStatus.completed) {
        _animationController.forward();
      }
    } else {
      if (_animationController.status != AnimationStatus.reverse &&
          _animationController.status != AnimationStatus.dismissed) {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    globalLightStateNotifier.removeListener(_onGlobalLightStateChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLight() {
    globalLightStateNotifier.value = !globalLightStateNotifier.value;
  }

  @override
  Widget build(BuildContext context) {
    // We use a Scaffold to ensure it takes up the full screen
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2E9),
      body: Stack(
        children: [
          // 1. Existing HTML Document via WebView
          // It fills the screen and is scrollable underneath the overlays
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: WebViewWidget(controller: _controller),
            ),
          ),

          // 2. Cinematic Lighting Overlay
          // This creates the realistic radial illumination effect over the rendered HTML content
          AnimatedBuilder(
            animation: _lightAnimation,
            builder: (context, child) {
              final double lightValue = _lightAnimation.value;

              // When OFF (lightValue = 0): Room becomes dark, document remains readable.
              // When ON (lightValue = 1): Document naturally illuminated, areas closer receive more light.
              return IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(
                        0,
                        -0.75,
                      ), // Centered directly beneath the bulb
                      radius:
                          1.6 -
                          (0.4 *
                              lightValue), // Falloff radius expands slightly when OFF to cover more
                      colors: [
                        // Center color
                        Color.lerp(
                          Colors.black.withOpacity(
                            0.85,
                          ), // OFF state: uniformly dark
                          Colors
                              .transparent, // ON state: fully illuminated center
                          lightValue,
                        )!,
                        // Edge color
                        Color.lerp(
                          Colors.black.withOpacity(
                            0.85,
                          ), // OFF state: uniformly dark matches center
                          Colors.black.withOpacity(
                            0.65,
                          ), // ON state: cinematic edge shadow
                          lightValue,
                        )!,
                      ],
                      stops: const [0.1, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),

          // 3. Interactive 3D Hanging Bulb
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _lightAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 300),
                    painter: BulbPainter(lightIntensity: _lightAnimation.value),
                  );
                },
              ),
            ),
          ),

          // Close button to go back to previous screen
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left:
                16, // Moved to left to avoid clashing with the floating button
            child: PointerInterceptor(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
      // Floating toggle button positioned in the bottom-right corner
      floatingActionButton: PointerInterceptor(
        child: FloatingActionButton(
          onPressed: _toggleLight,
          backgroundColor: Colors.grey.shade900,
          elevation: 8,
          child: AnimatedBuilder(
            animation: _lightAnimation,
            builder: (context, child) {
              final double lightValue = _lightAnimation.value;
              return Icon(
                lightValue > 0.5 ? Icons.lightbulb : Icons.lightbulb_outline,
                color: Color.lerp(
                  Colors.white54,
                  Colors.amberAccent,
                  lightValue,
                ),
                size: 28,
              );
            },
          ),
        ),
      ),
    );
  }
}

class BulbPainter extends CustomPainter {
  final double lightIntensity;

  BulbPainter({required this.lightIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;

    canvas.save();
    // Scale everything down to 80% to make it smaller while maintaining the top anchor
    canvas.translate(centerX, 0);
    canvas.scale(0.8, 0.8);
    canvas.translate(-centerX, 0);

    final double topY = 0;
    final double bulbCenterY = 120;

    // 1. Hanging wire (with metallic gradient for realism)
    final wirePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(centerX - 1.5, 0),
        Offset(centerX + 1.5, 0),
        [Colors.black87, Colors.grey.shade500, Colors.black87],
        [0.0, 0.5, 1.0],
      )
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(centerX, topY),
      Offset(centerX, bulbCenterY - 45),
      wirePaint,
    );

    // 2. Premium Metallic socket
    final socketRect = Rect.fromCenter(
      center: Offset(centerX, bulbCenterY - 35),
      width: 18,
      height: 24,
    );
    final socketPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(centerX - 9, 0),
        Offset(centerX + 9, 0),
        [
          const Color(0xFF333333),
          const Color(0xFFB0B0B0), // Brighter reflection
          const Color(0xFF222222),
        ],
        [0.0, 0.35, 1.0],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(socketRect, const Radius.circular(2)),
      socketPaint,
    );

    // Ridges with highlights for realism
    final ridgeShadow = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..strokeWidth = 1.0;
    final ridgeHighlight = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.0;
    for (int i = 0; i < 3; i++) {
      double ry = bulbCenterY - 42 + (i * 4);
      canvas.drawLine(
        Offset(centerX - 9, ry),
        Offset(centerX + 9, ry),
        ridgeShadow,
      );
      canvas.drawLine(
        Offset(centerX - 9, ry + 1),
        Offset(centerX + 9, ry + 1),
        ridgeHighlight,
      );
    }

    // 3. Glass bulb shape
    final Path bulbPath = Path();
    bulbPath.moveTo(centerX - 9, bulbCenterY - 23);
    bulbPath.cubicTo(
      centerX - 12,
      bulbCenterY - 15,
      centerX - 35,
      bulbCenterY - 5,
      centerX - 35,
      bulbCenterY + 15,
    );
    bulbPath.arcToPoint(
      Offset(centerX + 35, bulbCenterY + 15),
      radius: const Radius.circular(35),
      clockwise: false,
    );
    bulbPath.cubicTo(
      centerX + 35,
      bulbCenterY - 5,
      centerX + 12,
      bulbCenterY - 15,
      centerX + 9,
      bulbCenterY - 23,
    );
    bulbPath.close();

    // 4. Premium Glow (When ON)
    if (lightIntensity > 0) {
      // Massive soft outer halo
      final haloPaint = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.15 * lightIntensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 120 * lightIntensity);
      canvas.drawCircle(Offset(centerX, bulbCenterY + 15), 140, haloPaint);

      // Inner bright intense glow
      final glowOuterPaint = Paint()
        ..color = const Color(0xFFFFE082).withOpacity(0.4 * lightIntensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 60 * lightIntensity);
      canvas.drawCircle(Offset(centerX, bulbCenterY + 10), 80, glowOuterPaint);

      // Core white-hot glow
      final glowInnerPaint = Paint()
        ..color = const Color(0xFFFFFFFF).withOpacity(0.8 * lightIntensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 * lightIntensity);
      canvas.drawCircle(Offset(centerX, bulbCenterY + 10), 30, glowInnerPaint);
    }

    // 5. Glass material fill
    final glassPaint = Paint()
      ..color = Color.lerp(
        Colors.white.withOpacity(0.1), // Clearer glass when OFF
        Colors.white.withOpacity(0.5), // Glowing hot glass when ON
        lightIntensity,
      )!
      ..style = PaintingStyle.fill;
    canvas.drawPath(bulbPath, glassPaint);

    // 6. Realistic Filament Structure
    final Path filamentPath = Path();
    filamentPath.moveTo(centerX - 4, bulbCenterY - 23); // start at socket
    filamentPath.lineTo(centerX - 4, bulbCenterY - 2); // down
    filamentPath.lineTo(centerX - 10, bulbCenterY + 8); // left slant
    filamentPath.lineTo(centerX + 10, bulbCenterY + 8); // across bottom
    filamentPath.lineTo(centerX + 4, bulbCenterY - 2); // right slant up
    filamentPath.lineTo(centerX + 4, bulbCenterY - 23); // back to socket

    final filamentBasePaint = Paint()
      ..color = Color.lerp(
        Colors.orange[900],
        const Color(0xFFFFF176),
        lightIntensity,
      )!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(filamentPath, filamentBasePaint);

    // Glowing coil at bottom
    final coilPaint = Paint()
      ..color = Color.lerp(Colors.red[900], Colors.white, lightIntensity)!
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = lightIntensity > 0
          ? MaskFilter.blur(BlurStyle.solid, 6 * lightIntensity)
          : null;
    canvas.drawLine(
      Offset(centerX - 10, bulbCenterY + 8),
      Offset(centerX + 10, bulbCenterY + 8),
      coilPaint,
    );

    // 7. Premium Glass Specular Highlights (Reflection)
    // Left side curve reflection
    final highlightPath = Path();
    highlightPath.moveTo(centerX - 24, bulbCenterY + 2);
    highlightPath.arcToPoint(
      Offset(centerX - 12, bulbCenterY + 35),
      radius: const Radius.circular(30),
      clockwise: false,
    );
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.8 - (0.3 * lightIntensity))
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highlightPath, highlightPaint);

    // Small dot reflection on the right
    final dotHighlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.7 - (0.2 * lightIntensity))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas.drawCircle(
      Offset(centerX + 18, bulbCenterY + 22),
      2.5,
      dotHighlightPaint,
    );

    // 8. Thin rim lighting border
    final glassBorder = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(bulbPath, glassBorder);

    canvas.restore();
  }

  @override
  bool shouldRepaint(BulbPainter oldDelegate) {
    return oldDelegate.lightIntensity != lightIntensity;
  }
}
