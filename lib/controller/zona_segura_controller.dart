import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/model/xona_segura_model.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/pages/page_index/notificaciones_page.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ZonaSeguraController {
  final BuildContext context;
  final WidgetRef ref;

  ZonaSeguraController(this.context, this.ref);

  Future<bool> updateZonaSegura(ZonaSeguraModel model, int pacienteId) async {
    try {
      final options =
          ref.read(userCredentialsProvider.notifier).getDioOptions();
      final api = Api(ref).dio;
      final response = await api.put(
        '/updateZonaSegura',
        data: model.toJson(pacienteId),
        options: await options,
      );

      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (context) => const HomePage(),
        ),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (response.data['message'] ?? 'Se actualizó').toString(),
          ),
        ),
      );
      ref.invalidate(fetchNotificationsPacienteProvider);
      return true;
    } catch (e) {
      showDialogScope(context, ExceptionsUtils(e).toString());
      return false;
    }
  }
}
