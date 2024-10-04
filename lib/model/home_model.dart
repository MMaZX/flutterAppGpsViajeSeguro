import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final indexHomeProvider = StateProvider<int>((ref) {
  return indexList().first.index;
});

class HomeModel {
  final int index;
  final String title;
  final String? subtitle;
  final String? routeImage;
  final List<String>? estado;

  HomeModel(
      {required this.index,
      required this.title,
      this.subtitle,
      this.routeImage,
      this.estado});

  bool validateState(String rol) {
    if (!modelRolBase.contains(rol)) {
      throw Exception("No existe ese rol, no se mostrará el contenido.");
    }
    return true;
  }
}

List<HomeModel> indexList() {
  return [
    HomeModel(index: 1, title: "Dashboard"),
    HomeModel(index: 2, title: "Incidencias"),
    HomeModel(index: 3, title: "Iniciar Ruta"),
    HomeModel(index: 4, title: "Vehiculos"),
  ];
}
