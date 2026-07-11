import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import screens and core widgets
import 'screens/splash/splash_page.dart';
import 'screens/home/home_page.dart';
import 'screens/import/import_playlist_page.dart';
import 'screens/favorites/favorites_page.dart';
import 'screens/search/search_page.dart';
import 'widgets/navigation/bottom_navigation.dart';
import 'theme/app_theme.dart';
import 'services/storage/storage_service.dart';
import 'providers/state_providers.dart';

/// Entry point of the Nexora IPTV Player Application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure global Flutter error handling (UI and synchronous exceptions)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Nexora Global Error: ${details.exceptionAsString()}');
    debugPrint('Stacktrace: ${details.stack}');
  };

  // Configure platform error handling (asynchronous errors outside Flutter\'s context)
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Nexora Platform Dispatcher Error: $error');
    debugPrint('Stacktrace: $stack');
    return true; // Return true to indicate error has been handled
  };

  // Set system UI and orientations asynchronously to avoid blocking the first frame
  Future.microtask(() {
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    } catch (e) {
      debugPrint('Error setting UI overlay style: $e');
    }

    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (e) {
      debugPrint('Error setting preferred orientations: $e');
    }
  });

  // Pre-initialize SharedPreferences and register local storage service
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const NexoraApp(),
    ),
  );
}

/// GoRouter Route Configuration following Clean Architecture.
/// Contains routes for Slash, Home, Live TV, Search, Favorites, and Settings.
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashPage();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
    ),
    GoRoute(
      path: '/live_tv',
      builder: (BuildContext context, GoRouterState state) {
        return const LiveTvPage();
      },
    ),
    GoRoute(
      path: '/search',
      builder: (BuildContext context, GoRouterState state) {
        return const SearchPage();
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (BuildContext context, GoRouterState state) {
        return const FavoritesPage();
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const SettingsPage();
      },
    ),
    GoRoute(
      path: '/import_playlist',
      builder: (BuildContext context, GoRouterState state) {
        return const ImportPlaylistPage();
      },
    ),
  ],
);

/// Main App widget configuring Material 3 Dark Theme.
class NexoraApp extends StatelessWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nexora',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
    );
  }
}

// ============================================================================
// SUB-PAGE STUBS (Configured in routing structure)
// ============================================================================

class LiveTvPage extends StatelessWidget {
  const LiveTvPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Live TV')),
      body: const Center(child: Text('Live Stream Channels Category Selection')),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings, Cache controls, and Player Engines')),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 4),
    );
  }
}
