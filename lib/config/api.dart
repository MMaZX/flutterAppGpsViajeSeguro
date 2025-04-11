import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Endpoint {
  final BuildContext context;
  Endpoint({required this.context});

  static String apiHost = dotenv.env['API_HOST'].toString();
  String path = "$apiHost/api";

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
  //
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

class ApiEndpoint {
  final String prefix;
  ApiEndpoint(this.prefix);

  String endpoint(String endpoint) => "$prefix/$endpoint";
}

class ApiRoutes {
  static final _endpoints = <String, ApiEndpoint>{};
  static ApiEndpoint get(String prefix) {
    return _endpoints.putIfAbsent(prefix, () => ApiEndpoint(prefix));
  }

  /* # PREFIX */
  static final ApiEndpoint cuidador = get("/carer");
  static final ApiEndpoint listaDeSolicitudes = get("/list-requests");
  static final ApiEndpoint enviarSolicitud = get("/send-familiar");
  static final ApiEndpoint validarPaciente = get("/patientValidate");
  static final ApiEndpoint deleteCuidadorRequest = get("/remove-request");
  static final ApiEndpoint listaPacientesACuidar = get("/list-notifications-cuidador");
  /* # ENDPOITNS CUIDADOR */

  static final ApiEndpoint obtenerListaPacientesPorCuidador = get("/pacientesPorCuidadorId");
  static final ApiEndpoint obtenerListaFamiliaresPorCuidador =
      get("/familiarPorCuidadorId");

  // static String getCuidador =
  //     cuidador.endpoint("");
}
