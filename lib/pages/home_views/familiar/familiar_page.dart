import 'package:app_viaje_seguro/controller/cuidador_controller.dart';
import 'package:app_viaje_seguro/model/cuidador_model.dart';
import 'package:app_viaje_seguro/model/familiar_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:app_viaje_seguro/pages/home_views/familiar/data_familiar_paciente_page.dart';
import 'package:app_viaje_seguro/pages/home_views/familiar/familiar_aceptar_solicitudes_page.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FamiliarPage extends ConsumerStatefulWidget {
  const FamiliarPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FamiliarPageState();
}

class _FamiliarPageState extends ConsumerState<FamiliarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Familiares"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: FutureCustomWidget(
                future: CuidadorController(context, ref)
                    .obtenerFamiliaresPorCuidador(status: 1),
                widgetBuilder: (context, snapshot) {
                  final pacientes =
                      snapshot.data as List<FamiliarModelPaciente>;

                  if (pacientes.isEmpty) {
                    return const EmptyWidget(
                      "No tienes familiares aceptados, cuando te envien solicitudes de amistad, se mostraran aqui",
                    );
                  }

                  return ListView.builder(
                    itemCount: pacientes.length,
                    itemBuilder: (context, index) {
                      final data = pacientes[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: ShadImage.square(
                            LucideIcons.user,
                            size: 18,
                          ),
                        ),
                        title: Text(data.familiar!.name.toUpperCase()),
                        subtitle: Text("DNI: ${data.familiar!.identification}"),
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                    DataFamiliarPacientePage(data: data),
                              ));
                        },
                      );
                    },
                  );
                },
              ),
            ),
            ShadButton(
              width: double.maxFinite,
              onPressed: () async {
                await Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          const FamiliarAceptarSolicitudesPage(),
                    ));
                setState(() {});
              },
              child: const Text("Ver solicitudes pendientes"),
            ),
          ],
        ),
      ),
    );
  }
}
