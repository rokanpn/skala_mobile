import 'package:dio/dio.dart';
import 'package:skala_mobile/core/network/api_endpoints.dart';
import 'package:skala_mobile/core/storage/secure_storage.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            await _refreshToken();
            final newToken = await SecureStorage.getAccessToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            await SecureStorage.clearAll();
            // Navigate to login screen
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> _refreshToken() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token');

    final response = await Dio().post(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.refreshToken}',
      data: {'refresh_token': refreshToken},
    );

    await SecureStorage.saveTokens(
      accessToken: response.data['access_token'],
      refreshToken: response.data['refresh_token'],
    );
  }

  Dio get dio => _dio;
}
