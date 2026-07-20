import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/auth_provider.dart';
import '../core/theme.dart';
import '../services/biometric_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    // Wait for AuthNotifier's initial session restore (it starts loading=true).
    while (ref.read(authProvider).loading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    if (!mounted) return;
    final loggedIn = ref.read(authProvider).isLoggedIn;
    if (!loggedIn) {
      context.go('/login');
      return;
    }
    if (await BiometricService.instance.isEnabled()) {
      final ok = await BiometricService.instance.authenticate();
      if (!ok) {
        // Don't log them out over a cancelled biometric prompt — just retry.
        if (mounted) {
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) _decide();
        }
        return;
      }
    }
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.brand600,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, color: Colors.white, size: 56),
            SizedBox(height: 12),
            Text('KEBABADATAHUB', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            SizedBox(height: 24),
            SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
          ],
        ),
      ),
    );
  }
}
