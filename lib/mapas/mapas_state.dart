

// place_model.dart
class LugaresMapaState {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  LugaresMapaState({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory LugaresMapaState.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] ?? {};
    final geometry = json['geometry'] ?? {};
    final coordinates = geometry['coordinates'] ?? [0.0, 0.0];

    return LugaresMapaState(
      id: json['id'] ?? '',
      name: properties['name'] ?? '',
      address: properties['address'] ?? '',
      longitude: coordinates[0],
      latitude: coordinates[1],
    );
  }
}
