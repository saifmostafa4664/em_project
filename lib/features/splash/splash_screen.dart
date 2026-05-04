import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _bottomController;
  late AnimationController _pulseController;
  late AnimationController _dotController;

  // Logo
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // Text
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  // Bottom info
  late Animation<double> _bottomOpacity;

  // Pulse ring
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // Dots (loading)
  int _activeDot = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bottomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeOut),
    );
    _pulseScale = Tween<double>(begin: 0.8, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _bottomController.forward();
    _pulseController.repeat();

    // Animate dots
    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) setState(() => _activeDot = i % 3);
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) context.go(AppRouter.login);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bottomController.dispose();
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1B2341),
                  Color(0xFF0D1526),
                ],
              ),
            ),
          ),

          // Stars / dots background pattern
          ..._buildBackgroundDots(size),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Center logo + text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pulse rings + logo
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulse ring
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (_, __) => Transform.scale(
                              scale: _pulseScale.value,
                              child: Opacity(
                                opacity: _pulseOpacity.value,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Logo card
                          AnimatedBuilder(
                            animation: _logoController,
                            builder: (_, child) => Transform.scale(
                              scale: _logoScale.value,
                              child: Opacity(
                                opacity: _logoOpacity.value,
                                child: child,
                              ),
                            ),
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                color: AppColors.bgWhite,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Image.asset(
                                'assest/logo/363331987_257713613788245_2395123892953238221_n 1.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // University name + subtitle
                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            children: [
                              const Text(
                                'جامعة 6 أكتوبر\nالتكنولوجية',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Zain',
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textWhite,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  'نظام الحضور الذكي',
                                  style: TextStyle(
                                    fontFamily: 'Zain',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 60),

                      // RFID loading indicator
                      FadeTransition(
                        opacity: _bottomOpacity,
                        child: Column(
                          children: [
                            // Dot loader
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (i) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: i == _activeDot ? 20 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == _activeDot
                                        ? AppColors.primary
                                        : AppColors.primary.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'INITIALISING RFID ENGINE ◉',
                              style: TextStyle(
                                fontFamily: 'Zain',
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF8A94A6),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom info bar
                FadeTransition(
                  opacity: _bottomOpacity,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'تكنولوجيا الغد\nبأيدي اليوم',
                          style: TextStyle(
                            fontFamily: 'Zain',
                            fontSize: 10,
                            color: Color(0xFF4A5568),
                            height: 1.6,
                          ),
                        ),
                        const Text(
                          'SYSTEM VERSION\nV2.4.0–STABLE',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Zain',
                            fontSize: 10,
                            color: Color(0xFF4A5568),
                            height: 1.6,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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

  List<Widget> _buildBackgroundDots(Size size) {
    final dots = <Widget>[];
    final positions = [
      [0.1, 0.1], [0.9, 0.15], [0.05, 0.4], [0.95, 0.35],
      [0.15, 0.7], [0.85, 0.6], [0.4, 0.05], [0.6, 0.9],
      [0.3, 0.85], [0.7, 0.08],
    ];
    for (final pos in positions) {
      dots.add(Positioned(
        left: size.width * pos[0],
        top: size.height * pos[1],
        child: Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        ),
      ));
    }
    return dots;
  }
}
