class NotificationsState {
  final String title;
  final String body;
  final int idFamiliar;
  final int idCuidador;

  NotificationsState(
      {required this.title,
      required this.body,
      required this.idFamiliar,
      required this.idCuidador});

  factory NotificationsState.fromMap(Map<String, dynamic> map) {
    return NotificationsState(
      title: map['title'].toString(),
      body: map['body'].toString(),
      idFamiliar: int.parse(map['idPaciente'].toString()),
      idCuidador: int.parse(map['idCuidador'].toString()),
    );
  }

  NotificationsState copyWith({
    String? title,
    String? body,
    int? idPaciente,
    int? idCuidador,
  }) {
    return NotificationsState(
      title: title ?? this.title,
      body: body ?? this.body,
      idFamiliar: idPaciente ?? this.idFamiliar,
      idCuidador: idCuidador ?? this.idCuidador,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'idPaciente': idFamiliar,
      'idCuidador': idCuidador,
    };
  }
}
