import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamiliarController {
  final WidgetRef ref;
  final BuildContext context;

  FamiliarController({required this.ref, required this.context});

  Future<void> acceptRequest(int id) async {
    Dio api = Api(ref).dio;

    try {
      final response = await api.put('/accept-requests/$id');
      final json = response.data;
      showDialogResponse(context, json['message'] ?? 'Se aceptó', Container());
    } catch (e) {
      showDialogScope(context, ExceptionsUtils(e).toString());
    }
  }
}
