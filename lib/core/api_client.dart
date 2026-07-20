import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around the /api/mobile/* endpoints on kebabadatahub.com.ng.
/// Every method here maps to a real, already-tested PHP endpoint — see
/// public_html/api/mobile/ on the server for the source of truth.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));
  }

  static final ApiClient instance = ApiClient._internal();
  static const baseUrl = 'https://kebabadatahub.com.ng/api/mobile';
  static const _tokenKey = 'auth_token';

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
  Future<String?> readToken() => _storage.read(key: _tokenKey);
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
  Future<bool> isLoggedIn() async => (await readToken()) != null;

  // ---- Auth ----
  Future<Response> login(String email, String password, {String? deviceInfo}) => _dio.post(
        '/auth/login.php',
        data: {'email': email, 'password': password, 'device_info': deviceInfo},
      );

  Future<Response> register({
    required String fullname,
    required String email,
    required String phone,
    required String password,
    String? deviceInfo,
  }) =>
      _dio.post('/auth/register.php', data: {
        'fullname': fullname,
        'email': email,
        'phone': phone,
        'password': password,
        'device_info': deviceInfo,
      });

  Future<Response> logout() => _dio.post('/auth/logout.php');

  Future<Response> forgotPassword(String identifier) => _dio.post('/auth/forgot-password.php', data: {'identifier': identifier});

  Future<Response> resetPassword(String token, String password) =>
      _dio.post('/auth/reset-password.php', data: {'token': token, 'password': password});

  // ---- Profile / wallet ----
  Future<Response> getProfile() => _dio.get('/profile.php');

  Future<Response> updateProfile({String? fullname, String? phone}) =>
      _dio.put('/profile.php', data: {'fullname': fullname, 'phone': phone});

  Future<Response> uploadProfilePhoto(String filePath) => _dio.post(
        '/profile-photo.php',
        data: FormData.fromMap({'photo': MultipartFile.fromFileSync(filePath)}),
      );

  Future<Response> getBalance() => _dio.get('/wallet/balance.php');

  Future<Response> fundWallet(double amount) => _dio.post('/wallet/fund.php', data: {'amount': amount});

  Future<Response> fundingStatus(String reference) => _dio.get('/wallet/status.php', queryParameters: {'reference': reference});

  // ---- Services ----
  Future<Response> getPlans(String network) => _dio.get('/plans.php', queryParameters: {'network': network});

  Future<Response> buyAirtime({required String network, required num amount, required String phone}) =>
      _dio.post('/buy/airtime.php', data: {'network': network, 'amount': amount, 'phone': phone});

  Future<Response> buyData({required String network, required String plan, required String phone}) =>
      _dio.post('/buy/data.php', data: {'network': network, 'plan': plan, 'phone': phone});

  Future<Response> getTransactions({int page = 1}) => _dio.get('/transactions.php', queryParameters: {'page': page});

  // ---- Push ----
  Future<Response> registerDeviceToken(String fcmToken, {String? platform}) =>
      _dio.post('/device-token.php', data: {'fcm_token': fcmToken, 'platform': platform});
}

/// Standard shape every endpoint returns: {"success": bool, "message"?: string, "data"?: ...}
class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;

  /// Safe to call with whatever a bare `catch (e)` hands you — unlike
  /// fromDioError, this never assumes the exception is a DioException.
  static String describe(Object error) {
    if (error is DioException) return fromDioError(error).message;
    return 'Something went wrong — please try again.';
  }

  static ApiException fromDioError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return ApiException(data['message']);
    return ApiException('Network error — please check your connection and try again.');
  }
}
