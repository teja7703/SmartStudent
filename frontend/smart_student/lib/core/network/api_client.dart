import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        // Generous timeouts so the first request survives a Render free-tier
        // cold start (the instance can take ~30-50s to wake from idle).
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) {

    return _dio.post(path, data: data);
  }

  Future<Response<dynamic>> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }
}
