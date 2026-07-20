import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Face ID / fingerprint gate that sits in front of the app opening — it does
/// not replace the password login, it just re-confirms "this is really you"
/// on a device that already has a valid saved session (auth_token in secure
/// storage). Disabled by default; the user opts in from the Account screen.
class BiometricService {
  BiometricService._();
  static final instance = BiometricService._();

  final _auth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();
  static const _enabledKey = 'biometric_enabled';

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> isEnabled() async => (await _storage.read(key: _enabledKey)) == 'true';

  Future<void> setEnabled(bool enabled) => _storage.write(key: _enabledKey, value: enabled.toString());

  /// Prompts Face ID / fingerprint / device PIN fallback. Returns true only
  /// on a genuine successful match.
  Future<bool> authenticate({String reason = 'Confirm it\'s you to open KEBABADATAHUB'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
