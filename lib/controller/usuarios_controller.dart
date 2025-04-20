// ignore_for_file: use_build_context_synchronously

import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/model/usuario_model.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/services/location_stream_notification.dart';
import 'package:app_viaje_seguro/services/web_socket_service_background.dart';
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

  final prefs = AuthPrefs();

  Future<bool> updateUsuario(UsuarioModelData data, String password) async {
    try {
      final api = Api(ref).dio;
      final response = await api.put(
        '/users/update',
        data: data.toJson(password),
        options: await prefs.setDioOptions(),
      );
      print(response.data);

      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => const SesionPage(),
          ),
          (route) => false);
      showDialogResponse(
          context, "Se cerró sesión, vuelve a entrar.", Container());

      return true;
    } catch (e) {
      showDialogScope(context, ExceptionsUtils(e.toString()));
      return false;
    }
  }

  Future<bool> createUsuarios(BodyCreateUsuarios model) async {
    try {
      Dio api = Api(ref).dio;
      model.validateUserData();
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
      // isBackReturn(context);
      return true;
    } catch (e) {
      isBackReturn(context);
      showDialogScope(context, ExceptionsUtils(e).toString());
      return false;
    }
  }

  Future<bool> authLogin(String email, String password, AuthType tipo,
      {String faceIdToken = ''}) async {
    try {
      Dio api = Api(ref).dio;
      final response = await api.post('/auth/login', data: {
        "email": email,
        "password": password,
        "auth_type": tipo.name,
        "face_id_token": faceIdToken,
      });

      final json = response.data;
      final user = LoginResponse.fromJson(json['data']);
      isBackReturn(context);
      // RESPONSE
      setCorreo(email);
      setTipoRol(user.user.rol);
      setId(user.user.id.toString());
      // OTROS DATOS
      setFaceid(faceIdToken);
      setTipoAuth(tipo.name);
      setToken(user.token);
      isBackReturn(context);

      ref.watch(wsConnectionProvider.notifier).sendMessage({
        "type": "init",
        "userType": user.user.rol.toLowerCase().toString(),
        "userId": user.user.id,
      });
      ref.read(locationStreamProvider.notifier).start();
      return true;
    } catch (e) {
      isBackReturn(context);
      showDialogScope(context, e);
      return false;
    }
  }

  Future<void> setId(String value) async {
    try {
      if (value.isEmpty) {
        throw "El id no puede estar vacio";
      }
      final prefs = await SharedPreferences.getInstance();
      final id = int.parse(value);
      prefs.setInt(SharedToken.clienteId, id);
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<void> setTipoRol(String value) async {
    try {
      if (value.isEmpty) {
        throw "Tipo de rol vacio";
      }

      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedToken.clienteTipoRol, value);
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<void> setToken(String value) async {
    try {
      if (value.isEmpty) {
        throw "Token vacio";
      }
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedToken.clienteToken, value);
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<void> setCorreo(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedToken.clienteEmail, value);
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<void> setFaceid(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedToken.clienteFaceId, value);
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<void> setTipoAuth(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedToken.clienteTipo, value);
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<UsuarioModelData> getUsersById() async {
    try {
      Dio api = Api(ref).dio;
      int id = await AuthPrefs().getId();
      final response = await api.get(
        '/users/id',
        queryParameters: {
          'id': id,
        },
        options: await prefs.setDioOptions(),
      );
      final json = response.data;
      // print(json);
      return UsuarioModelData.fromJson(json);
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }
}

enum AuthType { email, faceid }

class AuthPrefs {
  Future<bool> isLoggedIn() async {
    final token = await getId();
    final rol = await getTipoRol();
    return token != 0 && rol.isNotEmpty;
  }

  Future<int> getId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(SharedToken.clienteId);
    if (id == null || id == 0) {
      return 0;
      throw "El id no puede estar vacío";
    }
    return id;
  }

  Future<String> getTipoRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedToken.clienteTipoRol) ?? "";
  }

  Future<String> getCorreo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedToken.clienteEmail) ?? "";
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedToken.clienteToken) ?? "";
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

class LoginResponse {
  final String token;
  final UserLoginResponse user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    try {
      final token =
          json['token'] ?? (throw "No se pudo obtener el valor de 'token'");
      final user =
          json['user'] ?? (throw "No se pudo obtener el valor de 'user'");

      return LoginResponse(
        token: token,
        user: UserLoginResponse.fromJson(user),
      );
    } catch (e) {
      throw "Error parsing LoginResponse: ${e.toString()}";
    }
  }
}

class UserLoginResponse {
  final int id;
  final String name;
  final String email;
  final String rol;

  UserLoginResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.rol,
  });

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] ?? (throw "No se pudo obtener el valor de 'id'");
      final name =
          json['name'] ?? (throw "No se pudo obtener el valor de 'name'");
      final email =
          json['email'] ?? (throw "No se pudo obtener el valor de 'email'");
      final rol = json['rol'] ?? (throw "No se pudo obtener el valor de 'rol'");

      return UserLoginResponse(
        id: id,
        name: name,
        email: email,
        rol: rol,
      );
    } catch (e) {
      throw "Error parsing UserLoginResponse: ${e.toString()}";
    }
  }
}
