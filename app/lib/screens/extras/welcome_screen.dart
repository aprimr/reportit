import 'package:app/core/routes/app_routes.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_buttons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:liquid_glass_plus/liquid_glass_plus.dart';
import 'package:video_player/video_player.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late Box<dynamic> box;
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/welcome.mp4')
      ..initialize()
          .then((_) {
            setState(() {
              _isVideoInitialized = true;
            });
            _controller.setLooping(true);
            _controller.setVolume(0);
            _controller.play();
          })
          .catchError((error) {
            setState(() {
              _isVideoInitialized = false;
            });
          });

    box = Hive.box('appBox');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _getStarted() async {
    box.put('isWelcomed', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.register);
    }
  }

  void _login() {
    box.put('isWelcomed', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Video
          if (_isVideoInitialized)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            // Fallback Image
            Image.asset(
              'assets/images/welcome.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1E3A5F), Color(0xFF0F172A)],
                    ),
                  ),
                );
              },
            ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Logo
                  Row(
                    children: [
                      Text(
                        'ReportIt',
                        style: GoogleFonts.oleoScript(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.appBarBg,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  LiquidGlassLayer(
                    settings: const LiquidGlassSettings(
                      thickness: 80,
                      frostIntensity: 3,
                      lightAngle: 0.7,
                    ),
                    child: LiquidGlass(
                      shape: LiquidRoundedSuperellipse(borderRadius: 30),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Report It,\nGet It Resolved.',
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Get Started
                            AppButtons.primary(
                              onPressed: _getStarted,
                              text: "Get Started",
                            ),

                            const SizedBox(height: 16),

                            // Sign In
                            Center(
                              child: AppButtons.text(
                                onPressed: _login,
                                textColor: Colors.white,
                                text: "Login",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
