import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'services/hive_service.dart';
import 'services/network_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'services/token_storage_service.dart';
import 'viewmodels/auth_view_model.dart';
import 'viewmodels/theme_view_model.dart';
import 'viewmodels/bookmark_view_model.dart';
import 'viewmodels/feed_view_model.dart';
import 'viewmodels/search_view_model.dart';
import 'viewmodels/story_threads_view_model.dart';
import 'viewmodels/reading_budget_view_model.dart';
import 'viewmodels/onboarding_view_model.dart';
import 'viewmodels/recommendation_view_model.dart';
import 'services/audio_briefing_service.dart';
import 'app_router.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}

  final hiveService = HiveService();

  // Initialize Firebase and Hive local boxes concurrently
  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    hiveService.init(),
  ]);

  runApp(
    BylineApp(
      hiveService: hiveService,
    ),
  );
}

class BylineApp extends StatefulWidget {
  final HiveService hiveService;

  const BylineApp({
    super.key,
    required this.hiveService,
  });

  @override
  State<BylineApp> createState() => _BylineAppState();
}

class _BylineAppState extends State<BylineApp> {
  late final NetworkService _networkService;
  late final FirebaseAuthService _firebaseAuthService;
  late final FirestoreService _firestoreService;
  late final TokenStorageService _tokenStorageService;

  late final AuthViewModel _authViewModel;
  late final ThemeViewModel _themeViewModel;
  late final RecommendationViewModel _recommendationViewModel;
  late final AudioBriefingService _audioBriefingService;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _networkService = NetworkService();
    _firebaseAuthService = FirebaseAuthService();
    _firestoreService = FirestoreService();
    _tokenStorageService = TokenStorageService();

    _authViewModel = AuthViewModel(
      authService: _firebaseAuthService,
      firestoreService: _firestoreService,
    );
    _themeViewModel = ThemeViewModel(hiveService: widget.hiveService);
    _recommendationViewModel = RecommendationViewModel(hiveService: widget.hiveService);
    _audioBriefingService = AudioBriefingService();

    _appRouter = AppRouter(_authViewModel, _recommendationViewModel);
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    _themeViewModel.dispose();
    _recommendationViewModel.dispose();
    _audioBriefingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<HiveService>.value(value: widget.hiveService),
        Provider<NetworkService>.value(value: _networkService),
        Provider<FirebaseAuthService>.value(value: _firebaseAuthService),
        Provider<FirestoreService>.value(value: _firestoreService),
        Provider<TokenStorageService>.value(value: _tokenStorageService),

        ChangeNotifierProvider<AuthViewModel>.value(value: _authViewModel),
        ChangeNotifierProvider<ThemeViewModel>.value(value: _themeViewModel),
        ChangeNotifierProvider<BookmarkViewModel>(
          create: (_) => BookmarkViewModel(
            hiveService: widget.hiveService,
            firestoreService: _firestoreService,
          ),
        ),
        ChangeNotifierProvider<FeedViewModel>(
          create: (_) => FeedViewModel(
            networkService: _networkService,
            hiveService: widget.hiveService,
          ),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(networkService: _networkService),
        ),
        ChangeNotifierProvider<StoryThreadsViewModel>(
          create: (_) => StoryThreadsViewModel(),
        ),
        ChangeNotifierProvider<ReadingBudgetViewModel>(
          create: (_) => ReadingBudgetViewModel(),
        ),
        ChangeNotifierProvider<OnboardingViewModel>(
          create: (_) => OnboardingViewModel(hiveService: widget.hiveService),
        ),
        ChangeNotifierProvider<RecommendationViewModel>.value(value: _recommendationViewModel),
        ChangeNotifierProvider<AudioBriefingService>.value(value: _audioBriefingService),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, child) {
          return MaterialApp.router(
            title: 'Byline',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeVM.themeMode,
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}
