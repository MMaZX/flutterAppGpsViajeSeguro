import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamiliarController {
  final WidgetRef ref;
  final BuildContext context;

  FamiliarController({required this.ref, required this.context});
  final api = Api().dio;

  Future<void> acceptRequest(int id) async {
    try {
      final response = await api.put('/accept-requests/$id');
      final json = response.data;
      showDialogResponse(context, json['message'] ?? 'Se aceptó', Container());
    } catch (e) {
      showDialogScope(context, ExceptionsUtils(e).toString());
    }
  }
}
