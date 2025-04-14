import 'package:app_viaje_seguro/controller/paciente_controller.dart';
import 'package:app_viaje_seguro/model/pacientes_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:app_viaje_seguro/pages/home_views/paciente_create.dart';
import 'package:app_viaje_seguro/pages/home_views/paciente_detalle.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PacientePage extends ConsumerStatefulWidget {
  const PacientePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PacientePageState();
}

class _PacientePageState extends ConsumerState<PacientePage> {
  List listaPacientes = [];

  @override
  Widget build(BuildContext context) {
    final controller = PacienteController(context, ref);
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pacientes"),
        actions: const [
          IconChangeTheme(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => const CrearPacientePage()));
          setState(() {});
        },
        child: const ShadImage.square(LucideIcons.userPlus, size: 24),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureCustomWidget(
                future: controller.getPacientes(),
                widgetBuilder: (context, snapshot) {
                  List listaPacientes = snapshot.data;
                  return listaPacientes.isEmpty
                      ? const EmptyWidget(
                          "No tienes algún paciente agregado, puedes agregar uno.")
                      : ListView.builder(
                          itemCount: listaPacientes.length,
                          itemBuilder: (context, index) {
                            PacientesModel paciente = listaPacientes[index];
                            return ListTile(
                              trailing: ShadButton.secondary(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) =>
                                          CupertinoAlertDialog(
                                            title:
                                                const Text("Eliminar paciente"),
                                            content: const Text(
                                                "¿Estás seguro de eliminar"),
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
                                                  controller.deletePaciente(
                                                      paciente.id);
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          ));
                                },
                                icon: const ShadImage.square(LucideIcons.trash2,
                                    size: 18),
                              ),
                              onTap: () => Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          PacientesPageDetalle(
                                              pacientesModel: paciente))),
                              leading: CircleAvatar(
                                child: Text(
                                  paciente.name.toUpperCase().substring(0, 1),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.p.copyWith(
                                    fontWeight: FontWeight.bold,
                                    height: 0,
                                    color: Colors.white,
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
                              subtitle: Text(paciente.relation),
                            );
                          },
                        );
                }),
          )
        ],
      ),
    );
  }
}
