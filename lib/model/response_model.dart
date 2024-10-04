class ResponseModel {
  final int statusCode;
  final String message;
  final String? dev;

  ResponseModel({required this.statusCode, required this.message, this.dev});

  factory ResponseModel.fromData(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return ResponseModel(
        statusCode: 0,
        message: "No existe respuesta, ha ocurrido un error",
        dev: "null",
      );
    }

    return ResponseModel(
      statusCode: json['statusCode'],
      message: json['message'],
      dev: json['dev'].toString(),
    );
  }
  factory ResponseModel.fromException(String message) {
    return ResponseModel(statusCode: 400, message: message);
  }
}
