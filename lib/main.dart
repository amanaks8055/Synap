import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'theme/app_theme.dart';
import 'blocs/favorites/favorites_bloc.dart';
import 'blocs/favorites/favorites_event.dart';
import 'blocs/premium/premium_bloc.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/tool_detail_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/voice_hub_screen.dart';
import 'screens/tracker/free_tier_tracker_screen.dart';
import 'blocs/tracker/tracker_bloc.dart';
import 'services/extension_sync_service.dart';
import 'services/supabase_service.dart';
import 'models/tool_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();   // ← SUPABASE INIT
  runApp(const SynapApp());
}

// ═══════════════════════════════════════════════════
// APP ROOT
// ═══════════════════════════════════════════════════
class SynapApp extends StatelessWidget {
  const SynapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FavoritesBloc()..add(LoadFavorites())),
        BlocProvider(create: (_) => PremiumBloc()),
        BlocProvider(create: (_) => TrackerBloc()),
      ],
      child: MaterialApp(
        title: 'Synap',
        debugShowCheckedModeBanner: false,
        theme: SynapTheme.darkTheme,
        initialRoute: '/auth',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  // ─── SAFE ROUTE GENERATION (no crash on null args) ─
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/auth':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AuthScreen(),
        );

      case '/home':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MainNavigation(),
        );

      case '/toolDetail':
        // CRASH PREVENTION: Safe cast with fallback
        final args = settings.arguments;
        if (args is Tool) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ToolDetailScreen(tool: args),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _AppEntry(),
        );

      case '/premium':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const PremiumScreen(),
        );

      case '/voice':
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => const VoiceHubScreen(),
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 400),
        );

      case '/onboarding':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AuthScreen(),
        );

      case '/tracker':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FreeTierTrackerScreen(),
        );

      default:
        // CRASH PREVENTION: Unknown route → fallback to home
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _AppEntry(),
        );
    }
  }
}

// ═══════════════════════════════════════════════════
// APP ENTRY — Splash → MainNavigation
// ═══════════════════════════════════════════════════
class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _showSplash = true;
  late ExtensionSyncService _syncService;

  @override
  void initState() {
    super.initState();
    _syncService = ExtensionSyncService(context.read<TrackerBloc>());
    _syncService.start();
  }

  @override
  void dispose() {
    _syncService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onDone: () {
        if (mounted) setState(() => _showSplash = false);
      });
    }
    
    // For now, always show onboarding to let user see the new setup
    // In production, we'd check if (supabase.auth.currentUser == null)
    return const AuthScreen();
  }
}

// ═══════════════════════════════════════════════════
// MAIN NAVIGATION — IndexedStack (no rebuild crash)
// ═══════════════════════════════════════════════════
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  // IndexedStack prevents screen rebuild crash
  final _screens = const [
    HomeScreen(),
    ExploreScreen(),
    FavoritesScreen(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: SynapColors.bgPrimary,
          border: Border(top: BorderSide(color: SynapColors.border, width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                _navItem(1, Icons.explore_rounded, Icons.explore_outlined, 'Explore'),
                _navItem(2, Icons.favorite_rounded, Icons.favorite_border_rounded, 'Favorites'),
                _navItem(3, Icons.menu_rounded, Icons.menu_outlined, 'Menu'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData active, IconData inactive, String label) {
    final sel = _index == i;
    return GestureDetector(
      onTap: () => setState(() => _index = i),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Corrected the problematic line based on the intent to change icon color
            Icon(sel ? active : inactive, color: sel ? SynapColors.accent : SynapColors.textMuted, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: sel ? SynapColors.accent : SynapColors.textMuted,
                fontSize: 11,
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
