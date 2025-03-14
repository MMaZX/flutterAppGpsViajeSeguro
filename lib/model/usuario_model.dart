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
