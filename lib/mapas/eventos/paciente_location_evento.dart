class PatientLocation {
  final String patientId;
  final double latitude;
  final double longitude;
  final bool? isInsideSafeZone;

  PatientLocation({
    required this.patientId,
    required this.latitude,
    required this.longitude,
    this.isInsideSafeZone,
  });

  factory PatientLocation.fromJson(Map<String, dynamic> json) {
    return PatientLocation(
      patientId: json['patientId'].toString(),
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      isInsideSafeZone: json['isInsideSafeZone'],
    );
  }
}
