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

  const DetailPage({
    super.key,
    required this.heroTag,
    this.child,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with SingleTickerProviderStateMixin {
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
        final String htmlContent = await rootBundle.loadString('assets/record_of_education.html');
        await _controller.loadHtmlString(htmlContent);
      } catch (e) {
        debugPrint('Error loading HTML: $e');
      }
    } else {
      // On mobile, we use loadFlutterAsset
      await _controller.loadFlutterAsset('assets/record_of_education.html');
    }
  }

  void _onGlobalLightStateChanged() {
    if (globalLightStateNotifier.value) {
      if (_animationController.status != AnimationStatus.forward && _animationController.status != AnimationStatus.completed) {
        _animationController.forward();
      }
    } else {
      if (_animationController.status != AnimationStatus.reverse && _animationController.status != AnimationStatus.dismissed) {
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
                      center: const Alignment(0, -0.75), // Centered directly beneath the bulb
                      radius: 1.6 - (0.4 * lightValue), // Falloff radius expands slightly when OFF to cover more
                      colors: [
                        // Center color
                        Color.lerp(
                          Colors.black.withOpacity(0.95), // OFF state: very dark
                          Colors.transparent, // ON state: fully illuminated center
                          lightValue,
                        )!,
                        // Edge color
                        Color.lerp(
                          Colors.black.withOpacity(0.98), // OFF state: almost pitch black
                          Colors.black.withOpacity(0.5), // ON state: cinematic shadow
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
            left: 16, // Moved to left to avoid clashing with the floating button
            child: PointerInterceptor(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          
          // Loading Indicator
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
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
                color: Color.lerp(Colors.white54, Colors.amberAccent, lightValue),
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
    // Shift everything up slightly to make the bulb smaller and higher
    final double topY = 0;
    final double bulbCenterY = 120;
    
    // 1. Hanging wire
    final wirePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(centerX, topY), Offset(centerX, bulbCenterY - 45), wirePaint);
    
    // 2. Metallic socket
    final socketRect = Rect.fromCenter(center: Offset(centerX, bulbCenterY - 35), width: 18, height: 24);
    final socketPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(centerX - 9, 0),
        Offset(centerX + 9, 0),
        [
          const Color(0xFF4A4A4A), // Dark left
          const Color(0xFF9E9E9E), // Light middle
          const Color(0xFF333333), // Dark right
        ],
        [0.0, 0.4, 1.0],
      );
    // Draw socket
    canvas.drawRRect(RRect.fromRectAndRadius(socketRect, const Radius.circular(2)), socketPaint);
    // Add some horizontal ridges to socket
    final ridgePaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(centerX - 9, bulbCenterY - 42), Offset(centerX + 9, bulbCenterY - 42), ridgePaint);
    canvas.drawLine(Offset(centerX - 9, bulbCenterY - 38), Offset(centerX + 9, bulbCenterY - 38), ridgePaint);
    canvas.drawLine(Offset(centerX - 9, bulbCenterY - 34), Offset(centerX + 9, bulbCenterY - 34), ridgePaint);
    
    // 3. Glass bulb shape
    final Path bulbPath = Path();
    bulbPath.moveTo(centerX - 9, bulbCenterY - 23);
    // Expand to round bulb
    bulbPath.cubicTo(
      centerX - 12, bulbCenterY - 15, 
      centerX - 35, bulbCenterY - 5, 
      centerX - 35, bulbCenterY + 15
    );
    // Bottom round part
    bulbPath.arcToPoint(
      Offset(centerX + 35, bulbCenterY + 15),
      radius: const Radius.circular(35),
      clockwise: false,
    );
    // Contract to socket
    bulbPath.cubicTo(
      centerX + 35, bulbCenterY - 5, 
      centerX + 12, bulbCenterY - 15, 
      centerX + 9, bulbCenterY - 23
    );
    bulbPath.close();

    // 4. Glow Behind Bulb (When ON)
    if (lightIntensity > 0) {
      final glowOuterPaint = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.25 * lightIntensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 80 * lightIntensity);
      canvas.drawCircle(Offset(centerX, bulbCenterY + 10), 90, glowOuterPaint);
      
      final glowInnerPaint = Paint()
        ..color = const Color(0xFFFFECB3).withOpacity(0.4 * lightIntensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 * lightIntensity);
      canvas.drawCircle(Offset(centerX, bulbCenterY + 10), 40, glowInnerPaint);
    }

    // 5. Glass material fill
    final glassPaint = Paint()
      ..color = Color.lerp(
        Colors.white.withOpacity(0.15), // OFF state glass
        const Color(0xFFFFF9C4).withOpacity(0.4), // ON state warm glass
        lightIntensity,
      )!
      ..style = PaintingStyle.fill;
    canvas.drawPath(bulbPath, glassPaint);

    // 6. Filament (Inside)
    final Path filamentPath = Path();
    filamentPath.moveTo(centerX - 4, bulbCenterY - 23); // start at socket
    filamentPath.lineTo(centerX - 4, bulbCenterY - 5);  // down
    filamentPath.lineTo(centerX - 8, bulbCenterY + 5);  // left slant
    filamentPath.lineTo(centerX + 8, bulbCenterY + 5);  // across bottom
    filamentPath.lineTo(centerX + 4, bulbCenterY - 5);  // right slant up
    filamentPath.lineTo(centerX + 4, bulbCenterY - 23); // back to socket

    final filamentBasePaint = Paint()
      ..color = Color.lerp(Colors.orange[900], Colors.yellow[100], lightIntensity)!
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(filamentPath, filamentBasePaint);

    // Glowing coil at bottom of filament
    final coilPaint = Paint()
      ..color = Color.lerp(Colors.red[800], Colors.white, lightIntensity)!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = lightIntensity > 0 ? MaskFilter.blur(BlurStyle.solid, 4 * lightIntensity) : null;
    canvas.drawLine(Offset(centerX - 8, bulbCenterY + 5), Offset(centerX + 8, bulbCenterY + 5), coilPaint);

    // 7. Glass Specular Highlight (Reflection)
    final highlightPath = Path();
    highlightPath.moveTo(centerX - 20, bulbCenterY + 5);
    highlightPath.arcToPoint(
      Offset(centerX - 10, bulbCenterY + 30),
      radius: const Radius.circular(20),
      clockwise: false,
    );
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6 - (0.4 * lightIntensity)) // Less visible when lit
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(highlightPath, highlightPaint);

    // 8. Bulb border
    final glassBorder = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(bulbPath, glassBorder);
  }

  @override
  bool shouldRepaint(BulbPainter oldDelegate) {
    return oldDelegate.lightIntensity != lightIntensity;
  }
}
