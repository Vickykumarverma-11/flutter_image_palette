import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dio_interceptor.dart';

class DioClient {
  Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://november7-730026606190.europe-west1.run.app',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    dio.interceptors.addAll([
      AppInterceptor(),
    ]);

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 15);
      return client;
    };

    return dio;
  }
}
