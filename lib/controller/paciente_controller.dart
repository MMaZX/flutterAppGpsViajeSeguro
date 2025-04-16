import 'dart:developer';

import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/cuidador_model_data.dart';
import 'package:app_viaje_seguro/model/pacientes_model.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PacienteController {
  final BuildContext context;
  final WidgetRef ref;

  PacienteController(this.context, this.ref);

  final prefs = AuthPrefs();

  Future<List<PacientesModel>> getPacientes() async {
    try {
      Dio dio = Api(ref).dio;

      final id = await AuthPrefs().getId();
      final response = await dio.get(
        '/patient/byFamily',
        queryParameters: {"id": id},
        options: await prefs.setDioOptions(),
      );
      final json = response.data;

      List<PacientesModel> list = [];
      for (var element in json) {
        list.add(PacientesModel.fromJson(element));
      }
      return list;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<bool> createPacientes(BodyCreatePacientes paciente) async {
    try {
      Dio dio = Api(ref).dio;

      final response = await dio.post(
        '/patient',
        data: paciente.toJson(),
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      print(json);
      isBackReturn(context);
      return true;
    } catch (e) {
      isBackReturn(context);
      showDialogScope(context, e);
      return false;
    }
  }

  Future<bool> deletePaciente(int id) async {
    try {
      Dio dio = Api(ref).dio;

      final response = await dio.delete(
        '/patient/$id',
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      print(json);
      return true;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<List<DataFormModelPage>> fetchCuidador() async {
    try {
      Dio dio = Api(ref).dio;
      final response = await dio.get(
        '/patient/cuidador',
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      List<DataFormModelPage> list = [];
      for (var element in json) {
        list.add(DataFormModelPage.fromMap(element));
      }
      return list;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<List<DataFormModelPage>> fetchFamiliar() async {
    try {
      Dio dio = Api(ref).dio;
      final response = await dio.get(
        '/patient/familiar',
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      List<DataFormModelPage> list = [];
      for (var element in json) {
        list.add(DataFormModelPage.fromMap(element));
      }
      return list;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }
}
