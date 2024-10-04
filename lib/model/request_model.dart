class RequestUpdateUserModel {
  final double? lat;
  final double? lng;
  final String? dni;
  final int? totalIncidencias;
  final int? numAsientos;
  final int? numAsientosActivos;
  final String? placa;

  RequestUpdateUserModel(
      {this.lat,
      this.lng,
      this.dni,
      this.totalIncidencias,
      this.numAsientos,
      this.numAsientosActivos,
      this.placa});

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'lng': lng,
      'dni': dni,
      'totalIncidencias': totalIncidencias,
      'numAsientos': numAsientos,
      'numAsientosActivos': numAsientosActivos,
      'placa': placa,
    };
  }
    Map<String, dynamic> toMapSelected() {
    return {
      'dni': dni,
      'numAsientos': numAsientos,
      'placa': placa,
    };
  }
}
