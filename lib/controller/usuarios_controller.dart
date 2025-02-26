import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/widgets/modal_widgets.dart';
import 'package:dio/dio.dart';
// import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsuariosController {
  final BuildContext context;
  final WidgetRef ref;

  UsuariosController(this.context, this.ref);

  final api = Api().dio;
  Future<bool> createUsuarios(BodyCreateUsuarios model) async {
    try {
      final response = await api.post('/auth/register', data: model.toMap());
      print(response.data);
      return true;
    } on DioException catch (e) {
      print(e.response?.data);
      showDialogScope(context, e);
      return false;
    }
  }
}
