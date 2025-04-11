class FamiliarModelPaciente {
  FamiliarModelPaciente({
    required this.familiar,
    required this.pacientes,
  });

  final DataModelFamiliar? familiar;
  final List<DataModelPaciente> pacientes;

  factory FamiliarModelPaciente.fromJson(Map<String, dynamic> json) {
    return FamiliarModelPaciente(
      familiar: json["familiar"] == null
          ? null
          : DataModelFamiliar.fromJson(json["familiar"]),
      pacientes: json["pacientes"] == null
          ? []
          : List<DataModelPaciente>.from(
              json["pacientes"]!.map((x) => DataModelPaciente.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "familiar": familiar?.toJson(),
        "pacientes": pacientes.map((x) => x.toJson()).toList(),
      };

  @override
  String toString() {
    return "$familiar, $pacientes, ";
  }
}

class DataModelFamiliar {
  DataModelFamiliar({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.identification,
    required this.image,
    required this.country,
    required this.address,
  });

  final int id;
  final String name;
  final String lastName;
  final String email;
  final String identification;
  final dynamic image;
  final String country;
  final String address;

  factory DataModelFamiliar.fromJson(Map<String, dynamic> json) {
    return DataModelFamiliar(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      lastName: json["last_name"] ?? "",
      email: json["email"] ?? "",
      identification: json["identification"] ?? "",
      image: json["image"],
      country: json["country"] ?? "",
      address: json["address"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "last_name": lastName,
        "email": email,
        "identification": identification,
        "image": image,
        "country": country,
        "address": address,
      };

  @override
  String toString() {
    return "$id, $name, $lastName, $email, $identification, $image, $country, $address, ";
  }
}

class DataModelPaciente {
  DataModelPaciente({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.image,
    required this.genre,
    required this.phone,
    required this.address,
  });

  final int id;
  final int userId;
  final String name;
  final int age;
  final dynamic image;
  final String genre;
  final String phone;
  final String address;

  factory DataModelPaciente.fromJson(Map<String, dynamic> json) {
    return DataModelPaciente(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? 0,
      name: json["name"] ?? "",
      age: json["age"] ?? 0,
      image: json["image"],
      genre: json["genre"] ?? "",
      phone: json["phone"] ?? "",
      address: json["address"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "name": name,
        "age": age,
        "image": image,
        "genre": genre,
        "phone": phone,
        "address": address,
      };

  @override
  String toString() {
    return "$id, $userId, $name, $age, $image, $genre, $phone, $address, ";
  }
}
