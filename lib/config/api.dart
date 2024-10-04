import 'package:flutter/material.dart';

class Endpoint {
  final BuildContext context;
  Endpoint({required this.context});

  // String path = "http://localhost/apiviajeseguro/public/api";
  String path = "http://192.168.1.22/apiviajeseguro/public/api";

  String getusuariosCRUD({bool isAction = false, String? id}) {
    if (isAction) {
      return "$path/${ContentApi.usuarios}/$id";
    }
    return "$path/${ContentApi.usuarios}";
  }

  String getPath(String content) {
    return "$path/$content";
  }

  String getPathById(String content, String id) {
    return "$path/$content/$id";
  }
}

class ContentApi {
  static String usuarios = "usuarios";
  static String dashboard = "dashboard";
  static String userbyId = "$usuarios/user";
  static String userbyDNI = "$usuarios/dni";
  static String usuariosActivosPorConducto = "$usuarios/conductor/activos";
  static String login = "login";
  static String vehiculos = "vehiculos";
  static String vehiculosPorDNI = "vehiculos/dni";
  static String vehiculosPorNombre = "vehiculos/nombre";
  static String crearIncidencia = "incidencias";
  //new
  /*
   */
  static String guardarVehiculoSolicitud =
      "vehiculos/state/guardar-vehiculo-solicitud";
  static String crearReporteViaje = "vehiculos/state/crear-reporte-viaje";
  static String actualizarReporteViajeFinalReal =
      "vehiculos/state/actualizar-reporte-viaje-final-real";
  //
  static String asientosPorVehiculo = "vehiculos/asientos";
  static String vehiculosIncidencias = "vehiculos/incidencias";
  static String vehiculosActivosBro = 'vehiculos/estado/viaje';
}
