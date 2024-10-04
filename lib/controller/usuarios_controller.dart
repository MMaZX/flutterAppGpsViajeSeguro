import 'dart:developer';
import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/model/response_model.dart';
import 'package:app_viaje_seguro/model/vehiculo_model.dart';
import 'package:app_viaje_seguro/pages/vehiculos_registrar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
//
import 'package:app_viaje_seguro/config/api.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//

class UsuariosController {
  final BuildContext context;
  final WidgetRef ref;

  UsuariosController({required this.context, required this.ref});

  Dio dio = Dio();

  Future<DniModel> getDni(String dni) async {
    try {
      final response = await dio
          .get('https://clientapi.sistemausqay.com/dni.php?documento=$dni');
      final json = response.data;
      DniModel model = DniModel.fromJson(json);
      return model;
    } on DioException catch (e) {
      print(e.response);
      return DniModel.fromDefault();
    }
  }

  Future<RucModel> getRUC(String ruc) async {
    try {
      final response = await dio
          .get('https://clientapi.sistemausqay.com/ruc.php?documento=$ruc');
      final json = response.data;
      RucModel model = RucModel.fromJson(json);
      return model;
    } on DioException catch (e) {
      print(e.response);
      return RucModel.fromDefault();
    }
  }

  Future<ResponseModel> createUser(UsuarioModel model) async {
    final path = Endpoint(context: context).getusuariosCRUD();
    print(path);
    try {
      if (model.toMap().isEmpty) {
        throw Exception(
            'Debe completar todos los campos para poder enviar el formulario');
      }
      final response = await dio.post(path, data: model.toMap());
      await getDataByUser(model.usuario);
      return ResponseModel.fromData(response.data);
    } catch (e) {
      log(e.toString());
      ResponseModel responseModel;
      if (e is DioException) {
        log("DIO EXCEPTION MANO : ${e.response}");
        responseModel = ResponseModel.fromData(e.response?.data ?? {});
      } else {
        responseModel = ResponseModel.fromException(e.toString());
      }
      return responseModel;
    }
  }

  Future<ResponseModel> loginSessionUser(
      {required String usuario, required String clave}) async {
    final path = Endpoint(context: context).getPath(ContentApi.login);
    print(path);
    try {
      if (usuario.isEmpty && clave.isEmpty) {
        throw Exception(
            'Usuario y contraseña no pueden estar vacíos, completar los campos y vuelva a intentarlo.');
      }

      final model = {
        "usuario": usuario,
        "clave": clave,
      };
      final response = await dio.post(path, data: model);

      if (response.data['statusCode'] != 200) {
        throw Exception(response.data['message'].toString());
      }

      await getDataByUser(usuario);
      return ResponseModel.fromData(response.data);
    } catch (e) {
      log(e.toString());
      ResponseModel responseModel;
      if (e is DioException) {
        log("DIO EXCEPTION MANO : ${e.response}");
        responseModel = ResponseModel.fromData(e.response?.data ?? {});
      } else {
        responseModel = ResponseModel.fromException(e.toString());
      }

      return responseModel;
    }
  }

  Future<List<UsuarioModel>> getAllUsers() async {
    final pathUser = Endpoint(context: context).getusuariosCRUD();
    try {
      final userData = await dio.get(pathUser);
      final json = userData.data;
      List<UsuarioModel> list = [];
      for (var item in json) {
        list.add(UsuarioModel.fromJson(item));
      }

      return list;
    } on DioException catch (e) {
      log(e.toString());
      throw Exception(e.response?.data['message'].toString() ??
          "No existe data para este usuario, ha ocurrido un error al tratar de recuperar la información");
    }
  }

  Future<List<UsuarioModel>> getAllConductorUsers() async {
    final pathUser = Endpoint(context: context).getusuariosCRUD();
    // print(pathUser);
    try {
      final userData = await dio.get(pathUser);
      final json = userData.data;
      List<UsuarioModel> list = [];
      for (var item in json) {
        if (item['rol'] == 'CONDUCTOR') {
          list.add(UsuarioModel.fromJson(item));
        }
      }
      if (list.isEmpty) {
        return [];
      }
      ref
          .read(usuarioSelectedVehiculoProvider.notifier)
          .update((state) => list.first.dni);
      return list;
    } on DioException catch (e) {
      log(e.toString());
      throw Exception(e.response?.data['message'].toString() ??
          "No existe data para este usuario, ha ocurrido un error al tratar de recuperar la información");
    }
  }

  Future<UsuarioModel> getDataByUser(String usuario) async {
    final pathUser =
        Endpoint(context: context).getPathById(ContentApi.userbyId, usuario);
    print(pathUser);
    try {
      final userData = await dio.get(pathUser);
      final item = userData.data;
      UsuarioModel modelData = UsuarioModel.fromJson(item);
      SharedToken().setLoginToken(modelData);
      return modelData;
    } on DioException catch (e) {
      log(e.toString());
      throw Exception(e.response?.data['message'].toString() ??
          "No existe data para este usuario, ha ocurrido un error al tratar de recuperar la información");
    }
  }

  Future<UsuarioModel> getDataByDNI(int dni) async {
    final pathUser = Endpoint(context: context)
        .getPathById(ContentApi.userbyDNI, dni.toString());
    print(pathUser);
    try {
      final userData = await dio.get(pathUser);
      final item = userData.data;
      UsuarioModel modelData = UsuarioModel.fromJson(item);
      SharedToken().setLoginToken(modelData);
      return modelData;
    } on DioException catch (e) {
      log(e.toString());
      throw Exception(e.response?.data['message'].toString() ??
          "No existe data para este usuario, ha ocurrido un error al tratar de recuperar la información");
    }
  }

  Future<List<ReporteViajeModel>> getUserActivesWithConductorDNI() async {
    final userModel = await SharedToken().getLoginToken();
    if (userModel.rol != 'CONDUCTOR') {
      return [];
    }

    final pathUser = Endpoint(context: context).getPathById(
        ContentApi.usuariosActivosPorConducto, userModel.dni.toString());
    // print(pathUser);
    try {
      final userData = await dio.get(pathUser);
      final json = userData.data;
      List<ReporteViajeModel> list = [];
      for (var item in json) {
        list.add(ReporteViajeModel.fromMap(item));
      }
      return list;
    } on DioException catch (e) {
      log(e.response.toString());
      return [];
    }
  }
}
