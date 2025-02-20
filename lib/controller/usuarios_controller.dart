import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsuariosController {
  final BuildContext context;
  final WidgetRef ref;

  UsuariosController({required this.context, required this.ref});

  Dio dio = Dio();


}
