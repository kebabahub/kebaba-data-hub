import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/auth_provider.dart';
import 'core/theme.dart';
import 'services/cache_service.dart';
import 'services/deep_link_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/wallet_fund_screen.dart';
import 'screens/buy_airtime_screen.dart';
import 'screens/buy_data_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/services_screen.dart';
import 'screens/profile_screen.dart';

// Firebase is intentionally NOT initialized here yet — see
// lib/services/push_service.dart for exactly what to uncomment once you've
// added google-services.json / GoogleService-Info.plist to the native
// projects. Until then the app runs fully without it; push notifications
// just stay inactive rather than crashing on missing config.
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.instance.init();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: KebabaApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
    GoRoute(path: '/reset-password', builder: (context, state) => ResetPasswordScreen(prefilledToken: state.extra as String?)),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/wallet/fund', builder: (context, state) => const WalletFundScreen()),
    GoRoute(path: '/buy/airtime', builder: (context, state) => const BuyAirtimeScreen()),
    GoRoute(path: '/buy/data', builder: (context, state) => const BuyDataScreen()),
    GoRoute(path: '/transactions', builder: (context, state) => const TransactionsScreen()),
    GoRoute(path: '/services', builder: (context, state) => const ServicesScreen()),
    GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
  ],
);

class KebabaApp extends ConsumerStatefulWidget {
  const KebabaApp({super.key});
  @override
  ConsumerState<KebabaApp> createState() => _KebabaAppState();
}

class _KebabaAppState extends ConsumerState<KebabaApp> {
  @override
  void initState() {
    super.initState();
    DeepLinkService.instance.init(_router);
  }

  @override
  void dispose() {
    DeepLinkService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KEBABADATAHUB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // mirrors the website's opt-in-via-system-or-toggle dark mode
      routerConfig: _router,
    );
  }
}
