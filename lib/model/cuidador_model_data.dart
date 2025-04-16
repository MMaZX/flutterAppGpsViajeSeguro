


class DataFormModelPage {
  final String name;
  final String relation;
  final String email;
  final String identification;
  final String country;
  final String address;
  final String status;

  DataFormModelPage({
    required this.name,
    required this.relation,
    required this.email,
    required this.identification,
    required this.country,
    required this.address,
    required this.status,
  });

  factory DataFormModelPage.fromMap(Map<String, dynamic> map) {
    return DataFormModelPage(
      name: (map['name'] ?? 'Nombre desconocido') as String,
      relation: (map['relation'] ?? 'Relación desconocida') as String,
      email: (map['email'] ?? 'Correo no disponible') as String,
      identification: (map['identification'] ?? 'Sin identificación') as String,
      country: (map['country'] ?? 'País no especificado') as String,
      address: (map['address'] ?? 'Dirección no disponible') as String,
      status: (map['status'] ?? 'INACTIVO') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relation': relation,
      'email': email,
      'identification': identification,
      'country': country,
      'address': address,
      'status': status,
    };
  }
}