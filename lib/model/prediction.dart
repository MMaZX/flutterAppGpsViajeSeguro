import 'dart:developer';

import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/controller/vehiculo_controller.dart';
import 'package:app_viaje_seguro/pages/conductor_page.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/pages/maps_restore.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong2/latlong.dart';

class UserActiveModel {
  final bool value;
  final int dniConductor;
  final int dniPasajero;
  final String address;
  final String latFinal;
  final String lngFinal;

  UserActiveModel({
    required this.value,
    required this.dniConductor,
    required this.dniPasajero,
    required this.address,
    required this.latFinal,
    required this.lngFinal,
  });

  UserActiveModel.isEmpty()
      : value = false,
        dniConductor = 0,
        dniPasajero = 0,
        address = '',
        latFinal = '',
        lngFinal = '';

  factory UserActiveModel.fromJson(Map<String, dynamic> json) {
    return UserActiveModel(
      value: bool.parse(json['value'].toString()),
      dniConductor: int.parse(json['dni_conductor'].toString()),
      dniPasajero: int.parse(json['dni_usuario'].toString()),
      address: json['address'].toString(),
      latFinal: json['lat_final'].toString(),
      lngFinal: json['lng_final'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'dni_conductor': dniConductor,
      'dni_usuario': dniPasajero,
      'address': address,
      'lat_final': latFinal,
      'lng_final': lngFinal,
    };
  }
}


