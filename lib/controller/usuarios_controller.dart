// ignore_for_file: use_build_context_synchronously

import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/model/usuario_model.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/widgets/modal_widgets.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:dio/dio.dart';
// import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuariosController {
  final BuildContext context;
  final WidgetRef ref;

  UsuariosController(this.context, this.ref);

  final api = Api().dio;
  Future<bool> createUsuarios(BodyCreateUsuarios model) async {
    try {
      final response = await api.post('/auth/register', data: model.toMap());

      final json = response.data;
      final data = json['data'];
      final user = ResponseUserModel.fromJson(data);

      setCorreo(user.email);
      setFaceid(user.faceIdToken.toString());
      setToken(user.token);

      if (user.faceIdToken == null) {
        setTipoAuth(AuthType.email.name);
      } else {
        setTipoAuth(AuthType.faceid.name);
      }
      isBackReturn(context);
      return true;
    } on DioException catch (e) {
      isBackReturn(context);
      print(e.response?.data);
      showDialogScope(context, e);
      return false;
    }
  }

  Future<bool> authLogin(String email, String password, AuthType tipo,
      {String faceIdToken = ''}) async {
    try {
      final response = await api.post('/auth/login', data: {
        "email": email,
        "password": password,
        "auth_type": tipo.name,
        "face_id_token": faceIdToken,
      });

      final json = response.data;
      print(json);
      isBackReturn(context);
      setCorreo(email);
      setFaceid(faceIdToken);
      setTipoAuth(tipo.name);
      setToken("");
      isBackReturn(context);
      //
      return true;
    } catch (e) {
      isBackReturn(context);
      showDialogScope(context, ExceptionsUtils(e).toString());
      return false;
    }
  }

  Future<void> setToken(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedToken.clienteToken, value);
    } catch (e) {
      showDialogScope(context, ExceptionsUtils(e).toString());
    }
  }

  Future<void> setCorreo(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedToken.clienteEmail, value);
    } catch (e) {
      showDialogScope(context, ExceptionsUtils(e).toString());
    }
  }

  Future<void> setFaceid(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedToken.clienteFaceId, value);
    } catch (e) {
      showDialogScope(context, ExceptionsUtils(e).toString());
    }
  }

  Future<void> setTipoAuth(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedToken.clienteTipo, value);
    } catch (e) {
      showDialogScope(context, ExceptionsUtils(e).toString());
    }
  }
}

enum AuthType { email, faceid }

class AuthPrefs {
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedToken.clienteToken) ?? "";
  }

  Future<String> getCorreo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedToken.clienteEmail) ?? "";
  }

  Future<String> getFaceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedToken.clienteFaceId) ?? "";
  }

  Future<String> getTipoAuth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedToken.clienteTipo) ?? "";
  }

  Future<Options> setDioOptions() async {
    final token = await getToken();
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }
}
