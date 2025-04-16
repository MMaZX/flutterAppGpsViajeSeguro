class ResponseUserModel {
  final String name;
  final String lastName;
  final String email;
  final String password;
  final String identification;
  final String country;
  final String address;
  final String token;
  final String? faceIdToken;
  final String rol;
  final int status;

  ResponseUserModel({
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.identification,
    required this.country,
    required this.address,
    required this.token,
    this.faceIdToken,
    required this.rol,
    required this.status,
  });

  /// Convierte un `Map<String, dynamic>` en una instancia de `ResponseUserModel`
  factory ResponseUserModel.fromJson(Map<String, dynamic> json) {
    return ResponseUserModel(
      name: json['name'],
      lastName: json['last_name'],
      email: json['email'],
      password: json['password'],
      identification: json['identification'],
      country: json['country'],
      address: json['address'],
      token: json['token'],
      faceIdToken: json['face_id_token'],
      rol: json['rol'],
      status: int.parse(json['status'].toString()),
    );
  }

  /// Convierte la instancia de `ResponseUserModel` en un `Map<String, dynamic>`
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'last_name': lastName,
      'email': email,
      'password': password,
      'identification': identification,
      'country': country,
      'address': address,
      'token': token,
      'face_id_token': faceIdToken, // Puede ser nulo
      'rol': rol,
      'status': status,
    };
  }
}

class UsuarioModelData {
  UsuarioModelData({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.password,
    required this.identification,
    required this.image,
    required this.country,
    required this.address,
    required this.token,
    required this.faceIdToken,
    required this.rol,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  final int id;
  final String name;
  final String lastName;
  final String email;
  final String password;
  final String identification;
  final dynamic image;
  final String country;
  final String address;
  final String token;
  final String faceIdToken;
  final String rol;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String user;

  UsuarioModelData copyWith({
    int? id,
    String? name,
    String? lastName,
    String? email,
    String? password,
    String? identification,
    String? image,
    String? country,
    String? address,
    String? token,
    String? faceIdToken,
    String? rol,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? user,
  }) {
    return UsuarioModelData(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      identification: identification ?? this.identification,
      image: image ?? this.image,
      country: country ?? this.country,
      address: address ?? this.address,
      token: token ?? this.token,
      faceIdToken: faceIdToken ?? this.faceIdToken,
      rol: rol ?? this.rol,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  factory UsuarioModelData.fromJson(Map<String, dynamic> json) {
    return UsuarioModelData(
      id: int.parse(json["id"].toString()),
      name: json["name"].toString(),
      lastName: json["last_name"].toString(),
      email: json["email"].toString(),
      password: json["password"].toString(),
      identification: json["identification"].toString(),
      image: json["image"],
      country: json["country"].toString(),
      address: json["address"].toString(),
      token: json["token"].toString(),
      faceIdToken: json["face_id_token"].toString(),
      rol: json["rol"].toString(),
      status: int.parse(json["status"].toString()),
      createdAt: DateTime.tryParse(json["created_at"].toString()),
      updatedAt: DateTime.tryParse(json["updated_at"].toString()),
      user: json["user"].toString(),
    );
  }

  Map<String, dynamic> toJson(String passwords) => {
        "id": id,
        "name": name,
        "last_name": lastName,
        "email": email,
        "password": password,
        "identification": identification,
        "image": image,
        "country": country,
        "address": address,
        "token": token,
        "face_id_token": faceIdToken,
        "rol": rol,
        "status": status,
        "user": user,
        "passwordOriginal": passwords,
      };

  @override
  String toString() {
    return "$id, $name, $lastName, $email, $password, $identification, $image, $country, $address, $token, $faceIdToken, $rol, $status, $createdAt, $updatedAt, $user, ";
  }
}

class UsuarioAccessModel {
  int id;
  String name;
  String lastName;
  String email;
  String identification;
  String? image;
  String country;
  String address;
  String token;
  String? faceIdToken;
  String rol;
  int status;
  String createdAt;
  String updatedAt;
  String user;

  UsuarioAccessModel({
    this.id = 0,
    this.name = '',
    this.lastName = '',
    this.email = '',
    this.identification = '',
    this.image,
    this.country = '',
    this.address = '',
    this.token = '',
    this.faceIdToken,
    this.rol = '',
    this.status = 0,
    this.createdAt = '',
    this.updatedAt = '',
    this.user = '',
  });

  /// Convierte un `Map<String, dynamic>` en una instancia de `UsuarioAccessModel`
  factory UsuarioAccessModel.fromJson(Map<String, dynamic> json) {
    return UsuarioAccessModel(
      id: json['id'],
      name: json['name'],
      lastName: json['last_name'],
      email: json['email'],
      identification: json['identification'].toString(),
      image: json['image'],
      country: json['country'],
      address: json['address'],
      token: json['token'],
      faceIdToken: json['face_id_token'],
      rol: json['rol'],
      status: json['status'],
      createdAt: json['created_at'].toString(),
      updatedAt: json['updated_at'].toString(),
      user: json['user'],
    );
  }

  /// Convierte la instancia de `UsuarioAccessModel` en un `Map<String, dynamic>`
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'last_name': lastName,
      'email': email,
      'identification': identification,
      'image': image,
      'country': country,
      'address': address,
      'token': token,
      'face_id_token': faceIdToken,
      'rol': rol,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user,
    };
  }

  /// Crea una copia de la instancia actual con valores opcionales actualizados
  UsuarioAccessModel copyWith({
    int? id,
    String? name,
    String? lastName,
    String? email,
    String? identification,
    String? image,
    String? country,
    String? address,
    String? token,
    String? faceIdToken,
    String? rol,
    int? status,
    String? createdAt,
    String? updatedAt,
    String? user,
  }) {
    return UsuarioAccessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      identification: identification ?? this.identification,
      image: image ?? this.image,
      country: country ?? this.country,
      address: address ?? this.address,
      token: token ?? this.token,
      faceIdToken: faceIdToken ?? this.faceIdToken,
      rol: rol ?? this.rol,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'last_name': lastName,
      'email': email,
      'identification': identification,
      'image': image,
      'country': country,
      'address': address,
      'token': token,
      'face_id_token': faceIdToken,
      'rol': rol,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user': user,
    };
  }
}
