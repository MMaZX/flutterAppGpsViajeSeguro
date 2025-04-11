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
  String user;
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
  int age;
  String phone;
  String genre;

  BodyCreateUsuarios({
    this.user = '',
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
    this.age = 0,
    this.phone = '',
    this.genre = '',
  });

  bool validateUserData() {
    Map<String, dynamic> userData = toMap();
    if (userData['user'] == null || userData['user'].toString().isEmpty) {
      return false;
    }
    if (userData['name'] == null || userData['name'].toString().isEmpty) {
      return false;
    }
    if (userData['last_name'] == null ||
        userData['last_name'].toString().isEmpty) {
      return false;
    }
    if (userData['email'] == null || userData['email'].toString().isEmpty) {
      return false;
    }
    if (userData['password'] == null ||
        userData['password'].toString().isEmpty) {
      return false;
    }
    if (userData['identification'] == null ||
        userData['identification'].toString().isEmpty) {
      return false;
    }
    if (userData['country'] == null || userData['country'].toString().isEmpty) {
      return false;
    }
    if (userData['address'] == null || userData['address'].toString().isEmpty) {
      return false;
    }
    if (userData['token'] == null || userData['token'].toString().isEmpty) {
      return false;
    }
    if (userData['rol'] == null || userData['rol'].toString().isEmpty) {
      return false;
    }
    if (userData['age'] == null) {
      return false;
    }
    if (userData['phone'] == null || userData['phone'].toString().isEmpty) {
      return false;
    }
    if (userData['genre'] == null || userData['genre'].toString().isEmpty) {
      return false;
    }

    // face_id_token is the only allowed nullable field
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
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
      'age': age,
      'phone': phone,
      'genre': genre,
    };
  }
}
