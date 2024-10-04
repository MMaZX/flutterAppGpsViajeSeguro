class IncidenciasModel {
  final int id;
  final String dni;
  final String comentario;
  final String incidenciasArray;
  final DateTime? dateTime;
  final int estado;
  final String nombreUsuario;
  final String celularUsuario;

  // Constructor
  IncidenciasModel({
    this.id = 0,
    required this.dni,
    required this.comentario,
    required this.incidenciasArray,
    this.dateTime,
    this.estado = 0,
    this.nombreUsuario = "",
    this.celularUsuario = "",
  });

  // Factory para crear la instancia desde un Map
  factory IncidenciasModel.fromMap(Map<String, dynamic> map) {
    return IncidenciasModel(
      id: map['id'],
      dni: map['dni'].toString(),
      comentario: map['comentario'].toString(),
      incidenciasArray: map['incidenciasArray'].toString(),
      dateTime: DateTime.parse(map['dateTime'].toString()),
      estado: map['estado'],
      nombreUsuario: map['nombre_usuario'].toString(),
      celularUsuario: map['celular_usuario'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dni': dni,
      'comentario': comentario,
      'incidenciasArray': incidenciasArray,
    };
  }
}
