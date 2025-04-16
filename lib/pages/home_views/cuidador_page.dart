import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/cuidador_controller.dart';
import 'package:app_viaje_seguro/model/cuidador_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:app_viaje_seguro/pages/home_views/cuidador_create.dart';
import 'package:app_viaje_seguro/pages/home_views/cuidador_perfil.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CuidadorPage extends ConsumerStatefulWidget {
  const CuidadorPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CuidadorPageState();
}

class _CuidadorPageState extends ConsumerState<CuidadorPage> {
  @override
  Widget build(BuildContext context) {
    final controller = CuidadorController(context, ref);
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cuidador"),
        actions: const [
          IconChangeTheme(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => const CrearCuidadorPage()));
          setState(() {});
        },
        child: const ShadImage.square(LucideIcons.userPlus, size: 24),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              child: FutureCustomWidget(
                  future: controller.getCuidadorPresets(),
                  widgetBuilder: (context, snapshot) {
                    List<CuidadorRequestValidate> listaPacientes =
                        snapshot.data;
                    return listaPacientes.isEmpty
                        ? const EmptyWidget(
                            "No tienes algún cuidador agregado, puedes agregar uno.")
                        : ListView.builder(
                            itemCount: listaPacientes.length,
                            itemBuilder: (context, index) {
                              CuidadorRequestValidate paciente =
                                  listaPacientes[index];
                              return ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                tileColor: paciente.status == 0
                                    ? Colors.redAccent.shade700
                                    : null,
                                trailing: paciente.status == 0
                                    ? null
                                    : ShadButton.secondary(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  CupertinoAlertDialog(
                                                    title: Text(
                                                      paciente.status == 1
                                                          ? "Eliminar solicitud enviada"
                                                          : "Eliminar Cuidador",
                                                    ),
                                                    content: const Text(
                                                        "¿Estás seguro de eliminar?"),
                                                    actions: [
                                                      CupertinoDialogAction(
                                                        child: const Text(
                                                            "Cancelar"),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      CupertinoDialogAction(
                                                        child: const Text(
                                                            "Eliminar"),
                                                        onPressed: () {
                                                          isBackReturn(context);
                                                          // showDialogLoading(
                                                          //     context);
                                                          CuidadorController(
                                                                  context, ref)
                                                              .deleteCuidador(
                                                                  paciente.id);
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ],
                                                  ));
                                        },
                                        icon: const ShadImage.square(
                                            LucideIcons.trash2,
                                            size: 18),
                                      ),
                                leading: CircleAvatar(
                                  child: Text(
                                    paciente.carer!.name
                                        .toUpperCase()
                                        .substring(0, 1),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onTap: () => Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          CuidadorPerfil(paciente.carer!),
                                    )),
                                title: Text(
                                  paciente.carer!.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    height: 0,
                                  ),
                                ),
                                // subtitle: Text(paciente.phone.toString()),
                                subtitle: Text(
                                  "SOLICITUD ${paciente.nameStatus} para ${paciente.patient!.name.toUpperCase()} | +51 ${paciente.carer!.phone}",
                                  style: theme.textTheme.muted.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
