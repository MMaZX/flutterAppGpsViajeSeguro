import 'dart:convert';

import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ModalException extends ConsumerWidget {
  final String error;
  const ModalException(this.error, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog.alert(
      title: const Text("Error inesperado"),
      description: Text(error),
      actions: [
        ShadButton.outline(
          child: const Text('Cancel'),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class ModalResponse extends ConsumerWidget {
  final String message;
  final Widget widget;
  const ModalResponse(this.message,
      {super.key, this.widget = const SizedBox.shrink()});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ShadDialog.alert(
      title: const Text("Se completó"),
      description: Text(message),
      actions: [
        ShadButton.outline(
          child: const Text('Cancelar'),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        widget
      ],
    );
  }
}

Future<void> showDialogScope(context, e, {bool isBack = false}) async {
  if (isBack) isBackReturn(context);
  await showDialog(
    context: context,
    builder: (context) => ModalException(ExceptionsUtils(e).toString()),
  );
}

Future<void> showDialogLoading(context) async {
  await showShadDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => const PopScope(
      canPop: false,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

isExceptionString(e) {
  return (e is Map<String, dynamic>
      ? e['message'] ?? 'Ocurrio un error al momento de terminar la solicitud.'
      : e.toString());
}

Future<void> showDialogResponse(context, String message, Widget widget) async {
  await showDialog(
    context: context,
    builder: (context) => ModalResponse(message, widget: widget),
  );
}

class ExceptionsUtils implements Exception {
  final dynamic e;

  ExceptionsUtils(this.e);

  String isException() {
    String error = "";
    if (e is DioException) {
      try {
        final errar = exceptionResponse(e);
        error = errar['message'].toString();
      } catch (era) {
        error = "No se pudo obtener la respuesta${exceptionResponse(e)}";
      }
    } else {
      error = e.toString();
    }
    return error;
  }

  Map<String, dynamic> exceptionResponse(DioException e) {
    final response = e.response;
    // Si tenemos una respuesta del servidor
    if (response != null) {
      // Si la respuesta contiene datos estructurados
      if (response.data is Map<String, dynamic>) {
        return {
          "statusCode": response.statusCode ?? 0,
          "message": response.data['message'] ?? "Error desconocido",
        };
      }
      // Si la respuesta es una cadena JSON
      if (response.data is String) {
        try {
          final Map<String, dynamic> jsonData = jsonDecode(response.data);
          return {
            "statusCode": response.statusCode ?? 0,
            "message": jsonData['message'] ?? "Error desconocido",
          };
        } catch (e) {
          // Si no podemos parsear el JSON
          return {
            "statusCode": response.statusCode ?? 0,
            "message": response.data.toString(),
          };
        }
      }
    }

    // Error por defecto si no podemos obtener más información
    return {
      "statusCode": 0,
      "message":
          "Ha ocurrido un error al momento de ejecutar la solicitud al servidor. Por favor, intente nuevamente.",
    };
  }

  @override
  String toString() {
    return isException().toString();
  }
}

/*

class ExceptionsUtils implements Exception {
  final dynamic e;

  ExceptionsUtils(this.e);

  String isException() {
    if (e is DioException) {
      final dioError = e as DioException;
      if (dioError.response?.data is Map<String, dynamic>) {
        return dioError.response?.data['message'] ??
            "DIO: Error desconocido al momento de hacer la petición al servidor.";
      }
      return _handleDioException(dioError);
    }
    if (e is Map<String, dynamic>) {
      return _handleMapException(e);
    }
    return e.toString();
  }

  String _handleDioException(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return "Tiempo de conexión con el servidor agotado";
      case DioExceptionType.sendTimeout:
        return "Tiempo de envío en conexión con el servidor agotado";
      case DioExceptionType.receiveTimeout:
        return "Tiempo de recepción en conexión con el servidor agotado";
      case DioExceptionType.badResponse:
        return "Código de estado inválido recibido: ${dioError.response?.statusCode}";
      case DioExceptionType.cancel:
        return "Solicitud al servidor cancelada";
      case DioExceptionType.unknown:
        return "Conexión con el servidor fallida debido a problemas de conexión a internet o problema desconocido";
      default:
        return "Error desconocido de DioException";
    }
  }

  String _handleMapException(Map<String, dynamic> errorMap) {
    final err = errorMap['message']?.toString() ?? "Error desconocido";
    return err.contains('Failed to connect')
        ? "No se obtuvo respuesta de la petición"
        : err;
  }

  @override
  String toString() => 'Error: ${isException()}';
}

 */


class NotFoundException implements Exception {
  final String e;
  NotFoundException(this.e);
  @override
  String toString() {
    return 'No se encontró el valor: $e';
  }
}

class UrlConfigException implements Exception {
  final String message;
  UrlConfigException(this.message);

  @override
  String toString() => 'UrlConfigException: $message';
}
