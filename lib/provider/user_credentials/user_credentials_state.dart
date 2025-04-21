class UserCredentials {
  final int id;
  final String tipoRol;
  final String token;
  final String correo;
  final String faceId;
  final String tipoAuth;

  const UserCredentials({
    required this.id,
    required this.tipoRol,
    required this.token,
    required this.correo,
    required this.faceId,
    required this.tipoAuth,
  });

  factory UserCredentials.empty() {
    return const UserCredentials(
      id: 0,
      tipoRol: '',
      token: '',
      correo: '',
      faceId: '',
      tipoAuth: '',
    );
  }

  bool get isLoggedIn => id != 0 && tipoRol.isNotEmpty;

  UserCredentials copyWith({
    int? id,
    String? tipoRol,
    String? token,
    String? correo,
    String? faceId,
    String? tipoAuth,
  }) {
    return UserCredentials(
      id: id ?? this.id,
      tipoRol: tipoRol ?? this.tipoRol,
      token: token ?? this.token,
      correo: correo ?? this.correo,
      faceId: faceId ?? this.faceId,
      tipoAuth: tipoAuth ?? this.tipoAuth,
    );
  }
}
