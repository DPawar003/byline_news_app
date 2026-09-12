import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/token_storage_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../viewmodels/recommendation_view_model.dart';

/// Splash screen that presents the Byline editorial brand and executes an
/// asynchronous auth token check before routing the user.
class SplashScreen extends StatefulWidget {
  final TokenStorageService? tokenStorageService;
  final FirebaseAuthService? authService;
  final Duration minDisplayDuration;
  final Duration authTimeout;

  const SplashScreen({
    super.key,
    this.tokenStorageService,
    this.authService,
    this.minDisplayDuration = const Duration(milliseconds: 750),
    this.authTimeout = const Duration(seconds: 4),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();

    // Start background auth token verification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndRoute();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndRoute() async {
    final tokenStorage =
        widget.tokenStorageService ?? TokenStorageService();
    final authService =
        widget.authService ??
        (context.mounted
            ? Provider.of<FirebaseAuthService>(context, listen: false)
            : FirebaseAuthService());

    RecommendationViewModel? recVM;
    if (context.mounted) {
      try {
        recVM = Provider.of<RecommendationViewModel>(context, listen: false);
      } catch (_) {}
    }

    String destination = '/login';

    try {
      // Execute token check concurrently with minimum brand display time
      final results = await Future.wait([
        _resolveAuthDestination(tokenStorage, authService, recVM)
            .timeout(widget.authTimeout),
        Future.delayed(widget.minDisplayDuration),
      ]);

      destination = results[0] as String;
    } catch (_) {
      // On network timeout or unhandled storage exception, gracefully fall back to /login
      destination = '/login';
    }

    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    context.go(destination);
  }

  
  ///    - On success: /home (or /onboarding)
  ///    - On failure: clear tokens, /login
  /// 3. Neither token exists -> /login
  Future<String> _resolveAuthDestination(
    TokenStorageService tokenStorage,
    FirebaseAuthService authService,
    RecommendationViewModel? recVM,
  ) async {
    final accessToken = await tokenStorage.getAccessToken();
    final refreshToken = await tokenStorage.getRefreshToken();

    final homeTarget = (recVM != null && !recVM.hasCompletedOnboarding)
        ? '/onboarding'
        : '/home';

    // 1. Valid access token exists
    if (accessToken != null && !tokenStorage.isTokenExpired(accessToken)) {
      return homeTarget;
    }

    // 2. Missing/expired access token, but refresh token exists -> silent refresh
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      try {
        final newAccessToken = await authService
            .attemptSilentRefresh(
              refreshToken: refreshToken,
              timeout: widget.authTimeout,
            );

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: refreshToken,
          );
          return homeTarget;
        } else {
          // Refresh failed -> clear stored credentials
          await tokenStorage.clearTokens();
          return '/login';
        }
      } catch (_) {
        await tokenStorage.clearTokens();
        return '/login';
      }
    }

    // 3. Neither token exists
    return '/login';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Editorial color tokens
    final bgColor = isDark ? const Color(0xFF1E1A17) : const Color(0xFFF7F3EC);
    final inkColor = isDark ? const Color(0xFFF7F3EC) : const Color(0xFF1B1F2B);
    final subtitleColor =
        isDark ? const Color(0xFFA5A19B) : const Color(0xFF6B6862);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Byline Monogram Icon
                  _BylineBrandMark(
                    isDark: isDark,
                    inkColor: inkColor,
                  ),
                  const SizedBox(height: 28),

                  // Editorial Wordmark
                  Text(
                    'BYLINE',
                    style: GoogleFonts.newsreader(
                      color: inkColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4.0,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Editorial Tagline & Accent Rule
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 1.5,
                        color: subtitleColor.withOpacity(0.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'INDEPENDENT JOURNALISM',
                          style: GoogleFonts.inter(
                            color: subtitleColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.2,
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 1.5,
                        color: subtitleColor.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders the signature Byline "B — LN" mark matching the app icon asset
class _BylineBrandMark extends StatelessWidget {
  final bool isDark;
  final Color inkColor;

  const _BylineBrandMark({
    required this.isDark,
    required this.inkColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF26221E) : const Color(0xFFEFECE5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: inkColor.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Center(
        child: Image.asset(
          isDark
              ? 'assets/icons/app_icon_dark.png'
              : 'assets/icons/app_icon_light.png',
          width: 80,
          height: 80,
          errorBuilder: (context, error, stackTrace) {
            // High-fidelity fallback vector if asset is loading
            return Text(
              'B',
              style: GoogleFonts.inter(
                color: inkColor,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            );
          },
        ),
      ),
    );
  }
}
