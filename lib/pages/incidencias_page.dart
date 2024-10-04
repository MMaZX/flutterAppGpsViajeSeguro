import 'package:app_viaje_seguro/controller/incidencias_controller.dart';
import 'package:app_viaje_seguro/model/incidencias_model.dart';
import 'package:app_viaje_seguro/provider/permission_provider.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IncidenciasPage extends ConsumerStatefulWidget {
  const IncidenciasPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncidenciasPageState();
}

class _IncidenciasPageState extends ConsumerState<IncidenciasPage> {
  @override
  Widget build(BuildContext context) {
    final permission = ref.watch(permissionProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Incidencias",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          Expanded(
            child: FutureCustomWidget(
              future: IncidenciasController(context).getIncidencias(),
              widgetBuilder: (context, snapshot) {
                List<IncidenciasModel> listModel = snapshot.data;

                if (listModel.isEmpty) {
                  return const Center(
                    child: Text(
                      "No existen incidencias",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: listModel.length,
                  itemBuilder: (context, index) {
                    final item = listModel[index];
                    return ExpansionTile(
                      leading: const Icon(
                        Icons.warning_rounded,
                        color: Colors.amber,
                      ),
                      title: Text(item.nombreUsuario),
                      subtitle: Text(item.dateTime.toString()),
                      children: [
                        ListTile(
                            title: const Text(
                              "INCIDENCIAS",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(item.incidenciasArray)),
                        ListTile(
                            title: const Text(
                              "Comentario del pasajero",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(item.comentario))
                      ],
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
