import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UsuarioModel {
  final String nombre;
  final String rol;
  final String usuario;
  final String password;

  UsuarioModel({required this.nombre, required this.rol, required this.usuario, required this.password});
}



enum RolUsuarioField{
familiar,
paciente
}