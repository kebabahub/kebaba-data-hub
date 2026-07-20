import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthState {
  const AuthState({this.user, this.loading = true});
  final AppUser? user;
  final bool loading;
  bool get isLoggedIn => user != null;

  AuthState copyWith({AppUser? user, bool? loading, bool clearUser = false}) => AuthState(
        user: clearUser ? null : (user ?? this.user),
        loading: loading ?? this.loading,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  final _api = ApiClient.instance;

  Future<void> _restoreSession() async {
    if (!await _api.isLoggedIn()) {
      state = state.copyWith(loading: false);
      return;
    }
    try {
      final res = await _api.getProfile();
      state = AuthState(user: AppUser.fromJson(res.data['data']), loading: false);
    } catch (_) {
      // Token expired or revoked — fall back to logged-out state.
      await _api.clearToken();
      state = const AuthState(loading: false);
    }
  }

  Future<void> login(String email, String password, {String? deviceInfo}) async {
    try {
      final res = await _api.login(email, password, deviceInfo: deviceInfo);
      await _api.saveToken(res.data['data']['token']);
      state = AuthState(user: AppUser.fromJson(res.data['data']['user']), loading: false);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> register({
    required String fullname,
    required String email,
    required String phone,
    required String password,
    String? deviceInfo,
  }) async {
    try {
      final res = await _api.register(fullname: fullname, email: email, phone: phone, password: password, deviceInfo: deviceInfo);
      await _api.saveToken(res.data['data']['token']);
      state = AuthState(user: AppUser.fromJson(res.data['data']['user']), loading: false);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Best-effort — clear local session regardless of network state.
    }
    await _api.clearToken();
    state = const AuthState(loading: false);
  }

  Future<void> refreshBalance() async {
    if (state.user == null) return;
    try {
      final res = await _api.getBalance();
      final balance = (res.data['data']['balance'] as num).toDouble();
      state = state.copyWith(user: state.user!.copyWith(balance: balance));
    } catch (_) {
      // Silent — balance just won't update this cycle, next poll will retry.
    }
  }

  Future<void> updateProfile({String? fullname, String? phone}) async {
    final res = await _api.updateProfile(fullname: fullname, phone: phone);
    state = state.copyWith(user: AppUser.fromJson(res.data['data']));
  }

  Future<void> uploadPhoto(String filePath) async {
    final res = await _api.uploadProfilePhoto(filePath);
    if (state.user != null) {
      state = state.copyWith(user: state.user!.copyWith(photoUrl: res.data['data']['photo_url']));
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
