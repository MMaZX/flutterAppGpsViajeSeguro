import 'dart:developer';

import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/pacientes_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PacienteController {
  final BuildContext context;
  final WidgetRef ref;

  PacienteController(this.context, this.ref);

  final prefs = AuthPrefs();
  final dio = Api().dio;

  Future<List<PacientesModel>> getPacientes() async {
    try {
      final response = await dio.get(
        '/patient',
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
      final response = await dio.post(
        '/patient',
        data: paciente.toJson(),
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      print(json);
      return true;
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }
}
