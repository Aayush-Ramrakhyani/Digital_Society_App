import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Main reveal sequence
  late final AnimationController _main;
  // Continuous ring rotation
  late final AnimationController _rotate;
  // Pulsing glow behind icon
  late final AnimationController _pulse;

  late final Animation<double> _arcDraw;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final List<Animation<double>> _letterFade;
  late final List<Animation<Offset>> _letterSlide;
  late final Animation<double> _tagFade;
  late final Animation<Offset> _tagSlide;
  late final Animation<double> _dotsFade;

  static const _name = 'Griha';

  @override
  void initState() {
    super.initState();

    _main = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _rotate = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 5000))
      ..repeat();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);

    // Arcs draw in during first half
    _arcDraw = CurvedAnimation(
        parent: _main,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut));

    // Logo elastic pop
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _main,
            curve: const Interval(0.08, 0.58, curve: Curves.elasticOut)));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _main,
            curve: const Interval(0.08, 0.32, curve: Curves.easeIn)));

    // Each letter of "Griha" staggers in
    _letterFade = List.generate(_name.length, (i) {
      final s = 0.42 + i * 0.05;
      return Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _main,
          curve: Interval(s, (s + 0.2).clamp(0.0, 1.0),
              curve: Curves.easeOut)));
    });
    _letterSlide = List.generate(_name.length, (i) {
      final s = 0.42 + i * 0.05;
      return Tween<Offset>(
              begin: const Offset(0, 1.2), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _main,
              curve: Interval(s, (s + 0.2).clamp(0.0, 1.0),
                  curve: Curves.easeOut)));
    });

    // Tagline and dots
    _tagFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _main,
            curve: const Interval(0.76, 0.96, curve: Curves.easeOut)));
    _tagSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _main,
            curve: const Interval(0.76, 0.96, curve: Curves.easeOut)));
    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _main,
            curve: const Interval(0.88, 1.0, curve: Curves.easeOut)));

    _main.forward();

    Timer(const Duration(milliseconds: 3400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginPage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  void dispose() {
    _main.dispose();
    _rotate.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryDark,
                AppTheme.primary,
                AppTheme.primaryLight,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo surrounded by animated rings
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_main, _rotate, _pulse]),
                  builder: (_, __) => SizedBox(
                    width: 210,
                    height: 210,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Decorative arcs via CustomPainter
                        CustomPaint(
                          size: const Size(210, 210),
                          painter: _RingPainter(
                            progress: _arcDraw.value,
                            rotation:
                                _rotate.value * 2 * math.pi,
                            pulse: _pulse.value,
                          ),
                        ),
                        // Icon tile
                        ScaleTransition(
                          scale: _logoScale,
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: Container(
                              width: 116,
                              height: 116,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(34),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accent
                                        .withValues(alpha: 0.55),
                                    blurRadius: 38,
                                    spreadRadius: 6,
                                  ),
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.22),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.home_rounded,
                                size: 68,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // "G · r · i · h · a" — each letter slides up individually
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _name.length,
                    (i) => Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 2),
                      child: FadeTransition(
                        opacity: _letterFade[i],
                        child: SlideTransition(
                          position: _letterSlide[i],
                          child: Text(
                            _name[i],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline
                SlideTransition(
                  position: _tagSlide,
                  child: FadeTransition(
                    opacity: _tagFade,
                    child: Text(
                      'Your Home, Your Community',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Wave dots loader
                FadeTransition(
                  opacity: _dotsFade,
                  child: const _WaveDots(),
                ),
                const SizedBox(height: 52),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Draws rotating saffron arc-dashes + white arc-dashes + pulsing glow
class _RingPainter extends CustomPainter {
  final double progress;
  final double rotation;
  final double pulse;

  const _RingPainter({
    required this.progress,
    required this.rotation,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Soft amber glow that breathes with pulse
    final glowPaint = Paint()
      ..color = AppTheme.accent
          .withValues(alpha: (0.05 + pulse * 0.10) * progress)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, 72 + pulse * 14, glowPaint);

    // Inner thin static circle
    canvas.drawCircle(
      center,
      66,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10 * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Outer saffron arc dashes — 6 arcs, rotate clockwise
    final p1 = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.85 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    final r1 = Rect.fromCircle(center: center, radius: 84);
    for (int i = 0; i < 6; i++) {
      canvas.drawArc(
          r1, rotation + i * (math.pi / 3), 0.42 * progress, false, p1);
    }

    // Outermost white arc dashes — 8 arcs, rotate counter-clockwise
    final p2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.22 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final r2 = Rect.fromCircle(center: center, radius: 100);
    for (int i = 0; i < 8; i++) {
      canvas.drawArc(
          r2, -rotation + i * (math.pi / 4), 0.28 * progress, false, p2);
    }

    // Small saffron dots at cardinal points of the middle ring
    final dotPaint = Paint()
      ..color = AppTheme.accent.withValues(alpha: 0.9 * progress)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final angle = rotation * 1.5 + i * (math.pi / 2);
      final x = center.dx + 84 * math.cos(angle);
      final y = center.dy + 84 * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 3.5 * progress, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.rotation != rotation ||
      old.pulse != pulse;
}

// Three dots that wave sequentially
class _WaveDots extends StatefulWidget {
  const _WaveDots();

  @override
  State<_WaveDots> createState() => _WaveDotsState();
}

class _WaveDotsState extends State<_WaveDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(3, (i) {
          final phase = i / 3.0;
          final t = (_c.value + phase) % 1.0;
          // sin wave: 0 at ends, 1 at peak
          final scale = math.sin(t * math.pi) * 0.65 + 0.35;
          return Padding(
            padding: EdgeInsets.only(right: i < 2 ? 9.0 : 0),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == 1
                      ? AppTheme.accent
                      : Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
