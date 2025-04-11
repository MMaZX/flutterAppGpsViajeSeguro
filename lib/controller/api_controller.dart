import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Api {
  late final Dio _dio;

  static String apiHost = dotenv.env['API_HOST'].toString();
  String path = "$apiHost/api";
  Api() {
    _dio = Dio(
      BaseOptions(
        baseUrl: path,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(ApiInterceptors());
  }

  Dio get dio => _dio;
}

class ApiInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('➡️ Enviando solicitud: ${options.method} ${options.uri}');
    log('Datos enviados: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('✅ Respuesta recibida: ${response.statusCode}');
    // log('🚀🚀 Body: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('❌ Error en la solicitud: ${jsonEncode(err.response?.data)}',
        error: err.response?.data);
    super.onError(err, handler);
  }
}
