import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

showDialogScope(BuildContext context, dynamic e) async {
  await showDialog(
    context: context,
    builder: (context) => ShadDialog.alert(
      title: const Text("Error"),
      description: Text(ExceptionsUtils(e).toString()),
      actionsAxis: Axis.vertical,
      actions: [
        ShadButton.outline(
          width: double.maxFinite,
          onPressed: () => isBackReturn(context),
          child: const Flexible(child: Text("Volver")),
        )
      ],
    ),
  );
}

showDialogLoading(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => const PopScope(
      canPop: false,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  );
}

class ExceptionsUtils implements Exception {
  final dynamic e;

  ExceptionsUtils(this.e);

  String isException() {
    if (e is DioException) {
      final dioError = e as DioException;
      if (dioError.response?.data is Map<String, dynamic>) {
        return dioError.response?.data['message'] ??
            "Error desconocido al momento de hacer la petición al servidor.";
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
