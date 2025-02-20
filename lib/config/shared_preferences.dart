import 'dart:convert';

import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedToken {
  static String tokenId = "tokenLogin";

  Future<SharedPreferences> setInstance() async =>
      await SharedPreferences.getInstance();

  Future<void> setLoginToken(UsuarioModel model) async {

  }

  Future<void> deleteLoginToken() async {
    SharedPreferences pref = await setInstance();
    pref.remove(tokenId);
  }

}
