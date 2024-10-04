import 'package:app_viaje_seguro/config/api.dart';
import 'package:app_viaje_seguro/model/incidencias_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DashboardController {
  Dio dio = Dio();

  final BuildContext context;
  DashboardController({required this.context});

  Future<DashboardModel> getDashboard() async {
    final path = Endpoint(context: context).getPath(ContentApi.dashboard);
    try {
      final response = await dio.get(path);

      return DashboardModel.fromJson(response.data);
    } catch (e) {
      print(e);
      return DashboardModel.fromJson(null);
    }
  }
}

class DashboardModel {
  final String totalUsuarios;
  final String totalVehiculos;
  final String totalIncidencias;
  final List<IncidenciasModel> modelIncidencias;
  final List<VehiculosRojosModel> modelVehiculos;

  DashboardModel({
    required this.totalUsuarios,
    required this.totalVehiculos,
    required this.totalIncidencias,
    this.modelIncidencias = const [],
    this.modelVehiculos = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic>? json) {
    try {
      if (json == null) {
        return DashboardModel(
            totalUsuarios: "", totalVehiculos: "", totalIncidencias: "");
      }
      return DashboardModel(
        totalUsuarios: json['total_usuarios'],
        totalVehiculos: json['total_vehiculos'],
        totalIncidencias: json['total_incidencias'],
        modelIncidencias: List<IncidenciasModel>.from(
            json['ultimas_incidencias']
                .map((x) => IncidenciasModel.fromMap(x))),
        modelVehiculos: List<VehiculosRojosModel>.from(
            json['total_vehiculos_rojos']
                .map((x) => VehiculosRojosModel.fromJson(x))),
      );
    } catch (e) {
      throw Exception("ERROR: $e");
    }
  }
}

class VehiculosRojosModel {
  final String dni;
  final String placa;
  final int total;

  VehiculosRojosModel(
      {required this.placa, required this.dni, required this.total});

  factory VehiculosRojosModel.fromJson(Map<String, dynamic> json) {
    return VehiculosRojosModel(
      dni: json['dni'],
      placa: json['placa'].toString().toUpperCase(),
      total: json['total_incidencias'],
    );
  }
}
