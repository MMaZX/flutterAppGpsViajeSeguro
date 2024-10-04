import 'package:app_viaje_seguro/config/api.dart';
import 'package:app_viaje_seguro/model/incidencias_model.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IncidenciasController {
  final BuildContext context;
  Dio dio = Dio();
  IncidenciasController(this.context);
  Future<void> createIncidencia(IncidenciasModel model) async {
    final path = Endpoint(context: context).getPath(ContentApi.crearIncidencia);
    try {
      var response = await dio.post(path, data: model.toMap());
      // isBackReturn(context);
      print(response.data);
      showSnackbarCustom(context, response.data['message']);
    } on DioException catch (e) {
      print(e.response);
      showSnackbarCustom(context, "Error al crear la incidencia, ERROR: $e");
    }
  }

  Future<List<IncidenciasModel>> getIncidencias() async {
    final path = Endpoint(context: context).getPath(ContentApi.crearIncidencia);

    try {
      final response = await dio.get(path);
      final json = response.data;
      final List<IncidenciasModel> listModel = [];
      for (var item in json) {
        listModel.add(IncidenciasModel.fromMap(item));
      }
      return listModel;
    } on DioException {
      // print(e.response);
      return [];
    }
  }
}

showSnackbarCustom(context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

showSnackbarCustomCloseSession(context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Cerrar Sesión',
        backgroundColor: Colors.redAccent.shade700,
        textColor: Colors.white,
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (context) => const SesionPage()),
            (route) => false,
          );
        },
      ),
    ),
  );
}
