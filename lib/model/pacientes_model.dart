
class PacientesModel {
  final int id;
  final int userId;
  final String name;
  final int age;
  final String? image;
  final String genre;
  final String? phone;
  final String? address;
  final String? ribbon;
  final String? qr;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PacientesModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    this.image,
    required this.genre,
    this.phone,
    this.address,
    this.ribbon,
    this.qr,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convertir JSON a Modelo
  factory PacientesModel.fromJson(Map<String, dynamic> json) {
    return PacientesModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      age: json['age'],
      image: json['image'],
      genre: json['genre'],
      phone: json['phone'],
      address: json['address'],
      ribbon: json['ribbon'],
      qr: json['qr'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convertir Modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'age': age,
      'image': image,
      'genre': genre,
      'phone': phone,
      'address': address,
      'ribbon': ribbon,
      'qr': qr,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
