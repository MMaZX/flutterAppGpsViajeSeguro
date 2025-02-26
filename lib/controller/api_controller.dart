import 'dart:developer';

import 'package:dio/dio.dart';

class Api {
  late final Dio _dio;

  Api() {
    _dio = Dio(
      BaseOptions(
        baseUrl:
            'http://192.168.2.100/api-alzsafe/public/api', // Cambia esto por la URL de tu API
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        log("Solicitud enviada a: ${options.uri}");
        print("Método: ${options.method}");
        print("Encabezados: ${options.headers}");
        print("Datos: ${options.data}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log("Respuesta recibida desde: ${response.requestOptions.uri}");
        print("Código de estado: ${response.statusCode}");
        print("Datos: ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        log("Error en la solicitud a: ${e.requestOptions.uri}");
        print("Mensaje de error: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;
}
