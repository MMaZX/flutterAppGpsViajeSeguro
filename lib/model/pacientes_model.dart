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
  final String relation;

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
    required this.relation,
  });

  // Convertir JSON a Modelo
  factory PacientesModel.fromJson(Map<String, dynamic> json) {
    return PacientesModel(
      id: json['id'],
      relation: json['relation'].toString().toUpperCase(),
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
}

class BodyCreatePacientes {
  String user;
  String name;
  String email;
  String dni;
  String password;
  int age;
  String genre;
  String phone;
  String address;
  String parentesco;
  String image;

  BodyCreatePacientes({
    this.user = '',
    this.name = '',
    this.email = '',
    this.password = '',
    this.dni = '',
    this.age = 0,
    this.genre = '',
    this.phone = '',
    this.address = '',
    this.parentesco = '',
    this.image = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'username': user,
      'name': name,
      'email': email,
      'password': password,
      'dni': dni,
      'age': age,
      'genre': genre,
      'phone': phone,
      'parentesco': parentesco,
      'address': address,
      'image': image,
    };
  }
}
