import 'dart:convert';

import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedToken {
  static String tokenId = "tokenLogin";

  Future<SharedPreferences> setInstance() async =>
      await SharedPreferences.getInstance();

  Future<void> setLoginToken(UsuarioModel model) async {
    SharedPreferences pref = await setInstance();
    final encode = jsonEncode(model.toMap());
    pref.setString(tokenId, encode);
  }

  Future<void> deleteLoginToken() async {
    SharedPreferences pref = await setInstance();
    pref.remove(tokenId);
  }

  Future<UsuarioModel> getLoginToken() async {
    try {
      SharedPreferences pref = await setInstance();
      String value = pref.getString(tokenId) ?? "";
      if (value.isEmpty) {
        return UsuarioModel.empty();
      }
      final decode = jsonDecode(value);
      UsuarioModel element = UsuarioModel.fromJson(decode);
      print(element.toMap());
      return element;
    } catch (e) {
      print(e);
      throw Exception("ERROR: $e");
    }
  }
}
