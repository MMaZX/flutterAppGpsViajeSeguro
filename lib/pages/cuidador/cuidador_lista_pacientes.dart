import 'package:app_viaje_seguro/controller/cuidador_controller.dart';
import 'package:app_viaje_seguro/model/cuidador_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:app_viaje_seguro/pages/cuidador/informacion_lista_pacientes.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CuidadorPageListaPacientes extends ConsumerStatefulWidget {
  const CuidadorPageListaPacientes({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CuidadorPageListaPacientesState();
}

class _CuidadorPageListaPacientesState
    extends ConsumerState<CuidadorPageListaPacientes> {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Pacientes"),
      ),
      body: FutureCustomWidget(
        future: CuidadorController(context, ref).obtenerPacientesPorCuidador(),
        widgetBuilder: (context, snapshot) {
          final pacientes = snapshot.data as List<DetalleDataModel>;

          if (pacientes.isEmpty) {
            return const EmptyWidget(
                "No tienes algún paciente, Revisa si tienes solicitudes pendientes de aprobar.");
          }

          return ListView.builder(
            itemCount: pacientes.length,
            itemBuilder: (context, index) {
              final paciente = pacientes[index];
              return ListTile(
                trailing: ShadButton.secondary(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                              title: const Text("Eliminar paciente"),
                              content: const Text("¿Estás seguro de eliminar"),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text("Cancelar"),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text("Eliminar"),
                                  onPressed: () {
                                    CuidadorController(context, ref)
                                        .deleteCuidador(paciente.idrequest);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ));
                  },
                  icon: const ShadImage.square(LucideIcons.trash2, size: 18),
                ),
                onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          InformacionListaPacientes(paciente: paciente),
                    )),
                leading: CircleAvatar(
                  child: Text(
                    paciente.name.toUpperCase().substring(0, 1),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.p.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 0,
                    ),
                  ),
                ),
                title: Text(
                  paciente.name.toUpperCase().toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 0,
                  ),
                ),
                subtitle: Text("Edad: ${paciente.age}"),
              );
            },
          );
        },
      ),
    );
  }
}
