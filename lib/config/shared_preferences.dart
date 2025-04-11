import 'dart:convert';

import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedToken {
  static String tokenId = "tokenLogin";
  static String clienteId = "clienteIdShared";
  static String clienteEmail = "clienteEmailShared";
  static String clientePassword = "clientePasswordShared";
  static String clienteToken = "clienteTokenShared";
  static String clienteFaceId = "clienteFaceIdShared";
  static String clienteTipo = "clienteTipoShared";
  static String clienteTipoRol = "clienteTipoRolShared";

  Future<SharedPreferences> setInstance() async =>
      await SharedPreferences.getInstance();

  Future<void> setLoginToken(UsuarioModel model) async {}

  Future<void> deleteLoginToken() async {
    SharedPreferences pref = await setInstance();
    pref.remove(tokenId);
  }
}
