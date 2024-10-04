class VehiculoModel {
  final int? id;
  final String? placa;
  final int? numAsientos;
  final String? dni;
  final String? nombreConductor;
  final String? celular;

  VehiculoModel({
    this.id,
    this.placa,
    this.numAsientos,
    this.dni,
    this.nombreConductor,
    this.celular,
  });

  factory VehiculoModel.fromGetDataJson(Map<String, dynamic> json) {
    return VehiculoModel(
      id: json['id'],
      placa: json['placa'],
      numAsientos: json['num_asientos'],
      dni: json['dni'],
    );
  }

  factory VehiculoModel.fromJson(Map<String, dynamic> json) {
    return VehiculoModel(
      id: json['id'],
      placa: json['placa'],
      numAsientos: json['num_asientos'],
      dni: json['dni'],
      nombreConductor: json['nombre_conductor'],
      celular: json['celular'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placa': placa,
      'num_asientos': numAsientos,
      'dni': dni,
    };
  }
}

class VehiculoSolicitudModel {
  String dniUsuario;
  int numAsientosActivos;
  int estado;

  VehiculoSolicitudModel({
    required this.dniUsuario,
    required this.numAsientosActivos,
    required this.estado,
  });

  // Crear un método fromMap si necesitas mapear desde un JSON a la clase.
  factory VehiculoSolicitudModel.toJson(Map<String, dynamic> map) {
    return VehiculoSolicitudModel(
      dniUsuario: map['dni_usuario'].toString(),
      numAsientosActivos: int.parse(map['num_asientos_activos'].toString()),
      estado: int.parse(map['estado'].toString()),
    );
  }
  // toMap para enviar los datos de Vehiculos Solicitud
  Map<String, dynamic> toMap() {
    return {
      'dni_usuario': dniUsuario,
      'num_asientos_activos': numAsientosActivos,
    };
  }


}

class ReporteViajeModel {
  final int? id;
  final String dniUsuario;
  final String dniConductor;
  final int numAsientos;
  final double lngInicial;
  final double latInicial;
  final double lngFinal;
  final double latFinal;
  final double? lngFinalReal;
  final double? latFinalReal;
  final String? direccionFinal;
  final int estado;

  ReporteViajeModel({
    this.id,
    required this.dniUsuario,
    required this.dniConductor,
    required this.numAsientos,
    required this.lngInicial,
    required this.latInicial,
    required this.lngFinal,
    required this.latFinal,
    this.lngFinalReal,
    this.latFinalReal,
    this.direccionFinal,
    required this.estado,
  });

  Map<String, dynamic> toMapForCreate() {
    return {
      'dni_usuario': dniUsuario,
      'dni_conductor': dniConductor,
      'num_asientos': numAsientos,
      'lng_inicial': lngInicial,
      'lat_inicial': latInicial,
      'lng_final': lngFinal,
      'lat_final': latFinal,
      'direccion_final': direccionFinal,
      'estado': estado,
    };
  }

  Map<String, dynamic> toMapForUpdate() {
    return {
      'id': id,
      'lng_final_real': lngFinalReal,
      'lat_final_real': latFinalReal,
    };
  }

  factory ReporteViajeModel.fromMap(Map<String, dynamic> map) {
    return ReporteViajeModel(
      id: map['id'],
      dniUsuario: map['dni_usuario'],
      dniConductor: map['dni_conductor'],
      numAsientos: map['num_asientos'],
      lngInicial: map['lng_inicial'],
      latInicial: map['lat_inicial'],
      lngFinal: map['lng_final'],
      latFinal: map['lat_final'],
      lngFinalReal: map['lng_final_real'],
      latFinalReal: map['lat_final_real'],
      direccionFinal: map['direccion_final'],
      estado: map['estado'],
    );
  }
}
