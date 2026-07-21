import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

/// Handles links like https://kebabadatahub.com.ng/reset-password?token=xxx
/// or kebabadatahub://reset-password?token=xxx opening directly inside the
/// app instead of a browser. Requires the domain-verification files below to
/// be hosted once you're ready to enable universal/app links:
///   - Android: public_html/.well-known/assetlinks.json
///   - iOS: public_html/.well-known/apple-app-site-association
/// Ask me to generate both once you have your app's package name / bundle ID
/// and signing certificate fingerprint (Android) ready.
class DeepLinkService {
  DeepLinkService._();
  static final instance = DeepLinkService._();

  final _appLinks = AppLinks();
  StreamSubscription? _sub;

  void init(GoRouter router) {
    _appLinks.uriLinkStream.listen((uri) => _handle(uri, router));
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handle(uri, router);
    });
  }

  void _handle(Uri uri, GoRouter router) {
    // Supports both the custom scheme (kebabadatahub://) and https universal
    // links to the same paths already used on the website.
    final path = uri.path.isEmpty ? '/' : uri.path;
    switch (path) {
      case '/reset-password':
        final token = uri.queryParameters['token'];
        if (token != null) router.push('/reset-password', extra: token);
        break;
      case '/transactions':
        router.push('/transactions');
        break;
      case '/dashboard':
        router.push('/dashboard');
        break;
      default:
        // Unknown deep link — land on the dashboard rather than doing nothing.
        router.push('/dashboard');
    }
  }

  void dispose() => _sub?.cancel();
}
