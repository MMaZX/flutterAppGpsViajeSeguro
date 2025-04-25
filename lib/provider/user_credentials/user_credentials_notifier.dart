import 'dart:developer';

import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_state.dart';
import 'package:app_viaje_seguro/services/background_services.dart';
import 'package:app_viaje_seguro/services/location_listener_notifier.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userCredentialsProvider =
    StateNotifierProvider<UserCredentialsNotifier, UserCredentials>(
  (ref) => UserCredentialsNotifier(ref),
);

class UserCredentialsNotifier extends StateNotifier<UserCredentials> {
  final Ref ref;
  UserCredentialsNotifier(this.ref) : super(UserCredentials.empty()) {
    loadFromPrefs();
  }

  Future<UserCredentials> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final value = UserCredentials(
      id: prefs.getInt(SharedToken.clienteId) ?? 0,
      tipoRol:
          (prefs.getString(SharedToken.clienteTipoRol) ?? '').toUpperCase(),
      token: prefs.getString(SharedToken.clienteToken) ?? '',
      correo: prefs.getString(SharedToken.clienteEmail) ?? '',
      faceId: prefs.getString(SharedToken.clienteFaceId) ?? '',
      tipoAuth: prefs.getString(SharedToken.clienteTipo) ?? '',
    );
    log('Cargando desde SharedPreferences: ${state.toString()}'); // Log de depuración}
    state = value;
    return value;
  }

  Future<void> setTipoRol(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedToken.clienteTipoRol, value);
    state = state.copyWith(tipoRol: value);
  }

  Future<void> setToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedToken.clienteToken, value);
    state = state.copyWith(token: value);
  }

  Future<void> setCorreo(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedToken.clienteEmail, value);
    state = state.copyWith(correo: value);
  }

  Future<void> setFaceId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedToken.clienteFaceId, value);
    state = state.copyWith(faceId: value);
  }

  Future<void> setTipoAuth(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedToken.clienteTipo, value);
    state = state.copyWith(tipoAuth: value);
  }

  Future<void> setId(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SharedToken.clienteId, value);
    state = state.copyWith(id: value);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = UserCredentials.empty();
    BackgroundServices().restartGPSconnection();


  }

  Future<Options> getDioOptions() async {
    return Options(
      headers: {
        'Authorization': 'Bearer ${state.token}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  Future<int> getId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(SharedToken.clienteId) ?? 0;
  }

  Future<String> getRol() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString(SharedToken.clienteTipoRol) ?? '').toUpperCase();
  }
}
