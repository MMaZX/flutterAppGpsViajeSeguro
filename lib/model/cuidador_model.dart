class CuidadorModel {
  final int id;
  final String userId;
  final String name;
  final int age;
  final String image;
  final String genre;
  final String phone;
  final String address;
  final String country;
  final int status;

  CuidadorModel({
required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.image,
    required this.genre,
    required this.phone,
    required this.address,
    required this.country,
    required this.status,
  });

  factory CuidadorModel.fromJson(Map<String, dynamic> json) {
    return CuidadorModel(
      id: int.parse(json['id'].toString()),
      userId: json['user_id'].toString(),
      name: json['name'].toString(),
      age: int.parse(json['age'].toString()),
      image: json['image'] ?? '',
      genre: json['genre'].toString(),
      phone: json['phone'].toString(),
      address: json['address'].toString(),
      country: json['country'].toString(),
      status: int.parse(json['status'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'age': age,
      'image': image,
      'genre': genre,
      'phone': phone,
      'address': address,
      'country': country,
      'status': status,
    };
  }
}



class PacienteModelValidacion {
  final int patientId;
  final String relation;
  final int familyId;
  final String name;
  final int age;
  final String genre;

  PacienteModelValidacion({
    required this.patientId,
    required this.relation,
    required this.familyId,
    required this.name,
    required this.age,
    required this.genre,
  });

  factory PacienteModelValidacion.fromJson(Map<String, dynamic> json) {
    return PacienteModelValidacion(
      patientId: json['patient_id'],
      relation: json['relation'],
      familyId: json['family_id'],
      name: json['name'],
      age: json['age'],
      genre: json['genre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'relation': relation,
      'family_id': familyId,
      'name': name,
      'age': age,
      'genre': genre,
    };
  }
}



class CuidadorRequestValidate {
  CuidadorRequestValidate({
    required this.id,
    required this.carerId,
    required this.patientId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.familiarId,
    required this.nameStatus,
    required this.patient,
    required this.carer,
  });

  final int id;
  final int carerId;
  final int patientId;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int familiarId;
  final String nameStatus;
  final DetalleDataModel? patient;
  final DetalleDataModel? carer;

  factory CuidadorRequestValidate.fromJson(Map<String, dynamic> json) {
    return CuidadorRequestValidate(
      id: json["id"] ?? 0,
      carerId: json["carer_id"] ?? 0,
      patientId: json["patient_id"] ?? 0,
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      familiarId: json["familiar_id"] ?? 0,
      nameStatus: json["nameStatus"] ?? "",
      patient: json["patient"] == null ? null : DetalleDataModel.fromJson(json["patient"]),
      carer: json["carer"] == null ? null : DetalleDataModel.fromJson(json["carer"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "carer_id": carerId,
        "patient_id": patientId,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "familiar_id": familiarId,
        "nameStatus": nameStatus,
        "patient": patient?.toJson(),
        "carer": carer?.toJson(),
      };

  @override
  String toString() {
    return "$id, $carerId, $patientId, $status, $createdAt, $updatedAt, $familiarId, $nameStatus, $patient, $carer, ";
  }
}

class DetalleDataModel {
  DetalleDataModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.image,
    required this.genre,
    required this.phone,
    required this.address,
    required this.country,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.ribbon,
    required this.qr,
  this.idrequest = 0,
    
  });

  final int id;
  final int userId;
  final String name;
  final int age;
  final dynamic image;
  final String genre;
  final String phone;
  final String address;
  final String country;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic ribbon;
  final dynamic qr;
  final int idrequest;



  factory DetalleDataModel.fromJson(Map<String, dynamic> json) {
    return DetalleDataModel(
      id: json["id"] ?? 0,
      userId: json["user_id"] ?? 0,
      name: json["name"] ?? "",
      age: json["age"] ?? 0,
      image: json["image"],
      genre: json["genre"] ?? "",
      phone: json["phone"] ?? "",
      address: json["address"] ?? "",
      country: json["country"] ?? "",
      status: json["status"] ?? 0,
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
      ribbon: json["ribbon"],
      qr: json["qr"],
      idrequest :json["id_request"] ?? 0,
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
        "country": country,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "ribbon": ribbon,
        "qr": qr,
      };

  @override
  String toString() {
    return "$id, $userId, $name, $age, $image, $genre, $phone, $address, $country, $status, $createdAt, $updatedAt, $ribbon, $qr, ";
  }
}
