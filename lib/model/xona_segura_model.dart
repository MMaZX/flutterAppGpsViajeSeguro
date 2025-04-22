class ZonaSeguraModel {
  final bool isZonaSegura;
  final double intervaloNotificaciones;
  final double intervaloInactividad;
  final double radioProteccion;
  final double latDefault;
  final double logDefault;
  

  ZonaSeguraModel({
    this.isZonaSegura = false,
    this.intervaloNotificaciones = 0.0,
    this.intervaloInactividad = 0.0,
    this.radioProteccion = 0.0,
    this.latDefault = 0.0,
    this.logDefault = 0.0,
  });
  bool get isEmpty {
    return !isZonaSegura &&
        intervaloNotificaciones == 0.0 &&
        intervaloInactividad == 0.0 &&
        radioProteccion == 0.0 &&
        latDefault == 0.0 &&
        logDefault == 0.0;
  }


  ZonaSeguraModel copyWith({
    bool? isZonaSegura,
    double? intervaloNotificaciones,
    double? intervaloInactividad,
    double? radioProteccion,
    double? latDefault,
    double? logDefault,
  }) {
    return ZonaSeguraModel(
      isZonaSegura: isZonaSegura ?? this.isZonaSegura,
      intervaloNotificaciones:
          intervaloNotificaciones ?? this.intervaloNotificaciones,
      intervaloInactividad: intervaloInactividad ?? this.intervaloInactividad,
      radioProteccion: radioProteccion ?? this.radioProteccion,
      latDefault: latDefault ?? this.latDefault,
      logDefault: logDefault ?? this.logDefault,
    );
  }

  factory ZonaSeguraModel.fromJson(Map<String, dynamic> json) {
    return ZonaSeguraModel(
      isZonaSegura: json['is_zona_segura'] ?? false,
      intervaloNotificaciones:
          (json['intervalo_notificaciones'] ?? 0).toDouble(),
      intervaloInactividad: (json['intervalo_inactividad'] ?? 0).toDouble(),
      radioProteccion: (json['radio_proteccion'] ?? 0).toDouble(),
      latDefault: (json['lat_default'] ?? 0).toDouble(),
      logDefault: (json['log_default'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_zona_segura': isZonaSegura,
      'intervalo_notificaciones': intervaloNotificaciones,
      'intervalo_inactividad': intervaloInactividad,
      'radio_proteccion': radioProteccion,
      'lat_default': latDefault,
      'log_default': logDefault,
    };
  }
}
