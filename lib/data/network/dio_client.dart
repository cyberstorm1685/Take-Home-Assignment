import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient([Dio? dio])
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      logPrint: (obj) => print("[API LOG] $obj"),
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    print("🔹 GET → $path");
    final response = await _dio.get(path, queryParameters: queryParameters);
    print(" Response Status: ${response.statusCode}");
    return response;
  }
}
