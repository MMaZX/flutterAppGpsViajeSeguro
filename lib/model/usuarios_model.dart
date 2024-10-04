import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UsuarioModel {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String dni;
  final String celular;
  final String usuario;
  final String clave;
  final String rol;
  final String? placa; // Nueva propiedad para almacenar la placa
  final int?
      numAsientos; // Nueva propiedad para almacenar el número de asientos
  final DateTime?
      createdAt; // Nueva propiedad para almacenar la fecha de creación
  final DateTime?
      updatedAt; // Nueva propiedad para almacenar la fecha de actualización

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';

  UsuarioModel({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.dni,
    required this.celular,
    required this.usuario,
    required this.clave,
    required this.rol,
    this.placa,
    this.numAsientos,
    this.createdAt,
    this.updatedAt,
  });

  UsuarioModel.empty()
      : nombre = '',
        apellidoPaterno = '',
        apellidoMaterno = '',
        dni = '',
        celular = '',
        usuario = '',
        clave = '',
        rol = '',
        placa = '',
        numAsientos = 0,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      nombre: json['nombre'],
      apellidoPaterno: json['apellido_paterno'],
      apellidoMaterno: json['apellido_materno'],
      dni: json['dni'],
      celular: json['celular'],
      usuario: json['usuario'],
      clave: json['clave'],
      rol: json['rol'],
      placa: json['placa'], // Asignar la nueva propiedad placa
      numAsientos:
          json['num_asientos'], // Asignar la nueva propiedad numAsientos
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(
              json['created_at'].toString()), // Parsear la fecha de creación
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at']
              .toString()), // Parsear la fecha de actualización
    );
  }

  // Convertir un objeto UsuarioModel a un mapa JSON para Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'dni': dni,
      'celular': celular,
      'usuario': usuario,
      'clave': clave,
      'rol': rol,
      'placa': placa, 
      'num_asientos': numAsientos,
    };
  }
}

List<String> modelRol = ['PASAJERO', 'CONDUCTOR'];
List<String> modelRolBase = ['PASAJERO', 'CONDUCTOR', 'ADMIN'];

enum RolEnumCliente {
  pasajero,
  conductor,
  admin,
}

void mostrarDialogo(BuildContext context, String mensaje) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Estado'),
          content: Text(mensaje),
          actions: [
            CupertinoButton(
              child: const Text('Aceptar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  });
}

class RucModel {
  String ruc;
  String razonSocial;
  String direccion;

  RucModel({
    required this.ruc,
    required this.razonSocial,
    required this.direccion,
  });

  factory RucModel.fromJson(Map<String, dynamic> json) => RucModel(
        ruc: json["ruc"],
        razonSocial: json["razon_social"],
        direccion: json["direccion"],
      );
  factory RucModel.fromDefault() =>
      RucModel(ruc: "", direccion: "", razonSocial: "");

  Map<String, dynamic> toJson() => {
        "ruc": ruc,
        "razon_social": razonSocial,
        "direccion": direccion,
      };
}

class DniModel {
  String dni;
  String nombres;
  String apellidos;
  String direccion;
  String email;

  DniModel({
    required this.dni,
    required this.nombres,
    required this.apellidos,
    required this.direccion,
    required this.email,
  });

  factory DniModel.fromJson(Map<String, dynamic> json) => DniModel(
        dni: json["dni"],
        nombres: json["nombres"],
        apellidos: json["apellidos"],
        direccion: json["direccion"],
        email: json["email"],
      );

  factory DniModel.fromDefault() =>
      DniModel(dni: "", nombres: "", apellidos: "", direccion: "", email: "");

  Map<String, dynamic> toJson() => {
        "dni": dni,
        "nombres": nombres,
        "apellidos": apellidos,
        "direccion": direccion,
        "email": email,
      };
}
