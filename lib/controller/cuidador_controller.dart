// ignore_for_file: use_build_context_synchronously

import 'package:app_viaje_seguro/config/api.dart';
import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/cuidador_model.dart';
import 'package:app_viaje_seguro/model/familiar_model.dart';
import 'package:app_viaje_seguro/services/notifications_controller_services.dart';
import 'package:app_viaje_seguro/services/notifications_state.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CuidadorController {
  final BuildContext context;
  final WidgetRef ref;

  CuidadorController(this.context, this.ref);

  final prefs = AuthPrefs();

  Future<List<CuidadorModel>> getByIdCuidador() async {
    try {
      Dio api = Api(ref).dio;
      final response = await api.get(
        ApiRoutes.cuidador.prefix,
        options: await prefs.setDioOptions(),
      );

      final json = response.data;
      List<CuidadorModel> cuidador = [];
      for (var item in json) {
        cuidador.add(CuidadorModel.fromJson(item));
      }
      return cuidador;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<List<CuidadorRequestValidate>> getCuidadorPresets() async {
    try {
      Dio api = Api(ref).dio;
      final response = await api.get(
        ApiRoutes.listaDeSolicitudes.prefix,
        options: await prefs.setDioOptions(),
      );

      final json = response.data;
      List<CuidadorRequestValidate> cuidador = [];
      for (var item in json) {
        cuidador.add(CuidadorRequestValidate.fromJson(item));
      }
      return cuidador;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<List<CuidadorModel>> getAllCuidador() async {
    try {
      Dio api = Api(ref).dio;

      final response = await api.get(
        ApiRoutes.cuidador.prefix,
        options: await prefs.setDioOptions(),
      );

      final json = response.data;
      List<CuidadorModel> cuidador = [];
      for (var item in json) {
        cuidador.add(CuidadorModel.fromJson(item));
      }
      return cuidador;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<bool> setInvitacion(
      {required int pacienteId, required int cuidadorId}) async {
    try {
      Dio api = Api(ref).dio;

      final response = await api.post(
        ApiRoutes.enviarSolicitud.prefix,
        data: {
          "patient_id": pacienteId,
          "cuidador_id": cuidadorId,
        },
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      // print(json.toString());

      final notifier =
          ref.watch(notificationControllerProvider).sendNotificationToUser(
                NotificationsState(
                  title: "Se ha enviado una solicitud",
                  body: "Un familiar a enviado la solicitud a un cuidador",
                  idFamiliar: json['id_familiar'],
                  idCuidador: json['id_cuidador'],
                ),
              );

      return true;
    } catch (e) {
      isBackReturn(context);
      showDialogScope(context, ExceptionsUtils(e).toString());
      return false;
    }
  }

  Future<List<PacienteModelValidacion>> fetchPatientValidate() async {
    try {
      Dio api = Api(ref).dio;

      final response = await api.get(
        ApiRoutes.validarPaciente.prefix,
        options: await prefs.setDioOptions(),
      );

      final json = response.data;
      List<PacienteModelValidacion> paciente = [];
      for (var item in json) {
        paciente.add(PacienteModelValidacion.fromJson(item));
      }
      return paciente;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<void> deleteCuidador(int id) async {
    try {
      Dio api = Api(ref).dio;

      final response = await api.post(
        ApiRoutes.deleteCuidadorRequest.prefix,
        data: {
          "id_request": id,
        },
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      // isBackReturn(context);
      showDialogResponse(context, json['message'], Container());
    } catch (e) {
      // isBackReturn(context);
      // throw ExceptionsUtils(e).toString();
      showDialogScope(context, ExceptionsUtils(e).toString());
    }
  }

  Future<List<CuidadorRequestValidate>> obtenerListaCuidador(
      {int status = 2}) async {
    try {
      Dio api = Api(ref).dio;

      final response = await api.get(
        ApiRoutes.listaPacientesACuidar.prefix,
        data: {
          "status": status,
        },
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      List<CuidadorRequestValidate> paciente = [];
      for (var item in json) {
        paciente.add(CuidadorRequestValidate.fromJson(item));
      }
      return paciente;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<List<FamiliarModelPaciente>> obtenerFamiliaresPorCuidador(
      {int status = 2}) async {
    try {
      Dio api = Api(ref).dio;

      final response = await api.get(
        ApiRoutes.obtenerListaFamiliaresPorCuidador.prefix,
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      List<FamiliarModelPaciente> paciente = [];
      for (var item in json) {
        paciente.add(FamiliarModelPaciente.fromJson(item));
      }
      return paciente;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<List<DetalleDataModel>> obtenerPacientesPorCuidador(
      {int status = 2}) async {
    try {
      Dio api = Api(ref).dio;

      final response = await api.get(
        ApiRoutes.obtenerListaPacientesPorCuidador.prefix,
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      List<DetalleDataModel> paciente = [];
      for (var item in json) {
        paciente.add(DetalleDataModel.fromJson(item));
      }
      return paciente;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }
}
