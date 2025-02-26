// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

class UsuarioModel {
  final String nombre;
  final String rol;
  final String usuario;
  final String password;

  UsuarioModel(
      {required this.nombre,
      required this.rol,
      required this.usuario,
      required this.password});
}

enum RolUsuarioField {
  // admin,
  cuidador,
  familiar,
  paciente,
}

class BodyCreateUsuarios {
  String name;
  String lastName;
  String email;
  String password;
  String identification;
  String country;
  String address;
  String token;
  String rol;
  String faceIdToken;

  BodyCreateUsuarios({
    this.name = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.identification = '',
    this.country = '',
    this.address = '',
    this.token = '',
    this.rol = '',
    this.faceIdToken = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'last_name': lastName,
      'email': email,
      'password': password,
      'identification': identification,
      'country': country,
      'address': address,
      'token': token,
      'rol': rol,
      'face_id_token': faceIdToken,
    };
  }
}
