import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'models/article.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/recommendation_view_model.dart';
import 'views/auth/login_screen.dart';
import 'views/main_shell.dart';
import 'views/search/search_screen.dart';
import 'views/bookmarks/bookmarks_screen.dart';
import 'views/article/article_detail_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/splash/splash_screen.dart';
import 'views/profile/security_privacy_screen.dart';

class AppRouter {
  final AuthViewModel authViewModel;
  final RecommendationViewModel? recommendationViewModel;

  AppRouter(this.authViewModel, [this.recommendationViewModel]);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: recommendationViewModel != null
        ? Listenable.merge([authViewModel, recommendationViewModel!])
        : authViewModel,
    redirect: (BuildContext context, GoRouterState state) {
      final isSplash = state.matchedLocation == '/splash';
      if (isSplash) {
        return null; // Allow splash screen to handle token verification and first-hop routing
      }

      final isAuthenticated = authViewModel.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        if (recommendationViewModel != null && !recommendationViewModel!.hasCompletedOnboarding) {
          return '/onboarding';
        }
        return '/home';
      }

      if (isAuthenticated &&
          recommendationViewModel != null &&
          !recommendationViewModel!.hasCompletedOnboarding &&
          !isOnboarding) {
        return '/onboarding';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShell(),
      ),

      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: '/security-privacy',
        builder: (context, state) => const SecurityPrivacyScreen(),
      ),
      GoRoute(
        path: '/article/:id',
        builder: (context, state) {
          final article = state.extra as Article?;
          if (article == null) {
            return const Scaffold(
              body: Center(child: Text('Article not found')),
            );
          }
          return ArticleDetailScreen(article: article);
        },
      ),
    ],
  );
}
