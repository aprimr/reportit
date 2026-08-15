import 'package:app/core/routes/app_routes.dart';
import 'package:app/core/storage/token_storage.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 10));
      if (!mounted) return;
      final box = Hive.box('appBox');
      final bool isWelcomed = box.get('isWelcomed', defaultValue: false);

      if (!isWelcomed) {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
        return;
      }

      // Get refresh token from secure storage
      final refreshToken = await TokenStorage.getRefreshToken();

      if (!mounted) return;
      if (refreshToken == null ||
          refreshToken.isEmpty ||
          JwtDecoder.isExpired(refreshToken)) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return;
      }

      try {
        final authService = ref.read(authServiceProvider);
        final response = await authService.refresh(refreshToken: refreshToken);

        final newAccessToken = response.data.accessToken;
        final newRefreshToken = response.data.refreshToken;

        // Save new access token to memory
        // TokenStorage.saveAccessToken(newAccessToken);

        // Save new access and refresh token in secure storage
        TokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        if (!mounted) return;

        Map<String, dynamic> decodedToken = JwtDecoder.decode(newAccessToken);
        String role = decodedToken['role'] ?? 'user';

        if (!mounted) return;

        // Navigate based on role
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, AppRoutes.adminDash);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            const Spacer(),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Report',
                    style: GoogleFonts.oleoScript(
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: 'It',
                    style: GoogleFonts.oleoScript(
                      fontSize: 34,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 58),
          ],
        ),
      ),
    );
  }
}
