import 'package:app_viaje_seguro/config/socket.dart';
import 'package:app_viaje_seguro/controller/cloud_controller.dart';
import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/prediction.dart';
import 'package:app_viaje_seguro/model/vehiculo_model.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class ConductorPage extends ConsumerStatefulWidget {
  final UserActiveModel userActiveModel;
  const ConductorPage({super.key, required this.userActiveModel});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConductorPageState();
}

class _ConductorPageState extends ConsumerState<ConductorPage> {
  late SocketController controller;
  @override
  void initState() {
    super.initState();
    controller = SocketController(ref: ref, context: context);
    controller.connectedSocket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bienvenido"),
        actions: const [IconChangeTheme()],
      ),
      body: Center(
          child: Column(
        children: [
          const ListTile(
            title: Text("Conductor"),
            subtitle: Text("Veamos que tienes por hacer"),
          ),
    
          ButtonCustomBase(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: const Text("¿Desea cerrar sesión?"),
                    actions: [
                      CupertinoDialogAction(
                        child: const Text("Cancelar"),
                        onPressed: () {
                          isBackReturn(context);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text("Volver al menú de inicio"),
                        onPressed: () async {
                          Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => const HomePage()),
                              (route) => false);
                        },
                      ),
                    ],
                  ),
                );
              },
              title: "Volver a la pantalla principal"),
        ],
      )),
    );
  }
}
