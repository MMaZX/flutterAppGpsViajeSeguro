// ignore_for_file: use_build_context_synchronously

import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/model/usuario_model.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:app_viaje_seguro/services/location_listener_notifier.dart';
import 'package:app_viaje_seguro/services/ws_listener_notifier.dart';
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

  Future<bool> updateUsuario(UsuarioModelData data, String password) async {
    try {
      final options =
          ref.read(userCredentialsProvider.notifier).getDioOptions();
      final api = Api(ref).dio;
      await api.put(
        '/users/update',
        data: data.toJson(password),
        options: await options,
      );
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

      final userNotifier = ref.read(userCredentialsProvider.notifier);
      await userNotifier.setCorreo(user.email);
      await userNotifier.setFaceId(user.faceIdToken.toString());
      await userNotifier.setToken(user.token);

      final tipoAuth =
          user.faceIdToken == null ? AuthType.email.name : AuthType.faceid.name;
      await userNotifier.setTipoAuth(tipoAuth);
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
      final watch = ref.watch(wsConnectionProvider.notifier);

      isBackReturn(context);
      // RESPONSE
      final userNotifier = ref.read(userCredentialsProvider.notifier);
      await userNotifier.setCorreo(email);
      await userNotifier.setTipoRol(user.user.rol);
      await userNotifier.setId(user.user.id);
      await userNotifier.setFaceId(faceIdToken);
      await userNotifier.setTipoAuth(tipo.name);
      await userNotifier.setToken(user.token);
      watch.sendMessage({
        "type": "init",
        "userType": user.user.rol.toLowerCase().toString(),
        "userId": user.user.id,
      });
      isBackReturn(context);
      ref.read(locationStreamProvider.notifier).startLocationStream();
      return true;
    } catch (e) {
      isBackReturn(context);
      showDialogScope(context, e);
      return false;
    }
  }

  Future<UsuarioModelData> getUsersById() async {
    try {
      Dio api = Api(ref).dio;
      int id = ref.read(userCredentialsProvider).id;
      final options =
          ref.read(userCredentialsProvider.notifier).getDioOptions();
      final response = await api.get(
        '/users/id',
        queryParameters: {
          'id': id,
        },
        options: await options,
      );
      final json = response.data;
      // print(json);
      return UsuarioModelData.fromJson(json);
    } catch (e) {
      throw ExceptionsUtils(e).toString();
    }
  }

  Future<int> getId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(SharedToken.clienteId);
    if (id == null || id == 0) {
      return 0;
      // throw "El id no puede estar vacío";
    }
    return id;
  }
}

enum AuthType { email, faceid }

// class AuthPrefs {
//   Future<String> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(SharedToken.clienteToken) ?? "";
//   }

//   Future<Options> setDioOptions() async {
//     final token = await getToken();
//     return Options(
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );
//   }
// }

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
