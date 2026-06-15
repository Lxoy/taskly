import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Singleton Dio klijent s interceptorima za:
///   • automatsko dodavanje JWT tokena na svaki request
///   • logging u debug modu
class ApiClient {
  static const String _tokenKey = 'auth_token';

  final Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient({
    required String baseUrl,
    FlutterSecureStorage? storage,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(_AuthInterceptor(_storage, _tokenKey));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }

  Dio get dio => _dio;

  // Token management
  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}

/// Interceptor koji čita JWT iz SecureStorage i dodaje ga
/// kao Authorization header na svaki request (osim auth ruta).
class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final String _tokenKey;

  _AuthInterceptor(this._storage, this._tokenKey);

  static const _publicRoutes = ['/api/auth/login', '/api/auth/register'];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic = _publicRoutes.any((r) => options.path.endsWith(r));

    if (!isPublic) {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }
}

// Potrebno za LogInterceptor u release buildu
void debugPrint(String message) {
  assert(() {
    // ignore: avoid_print
    print(message);
    return true;
  }());
}