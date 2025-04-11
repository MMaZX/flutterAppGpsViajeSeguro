import 'package:app_viaje_seguro/controller/cuidador_controller.dart';
import 'package:app_viaje_seguro/controller/familiar_controller.dart';
import 'package:app_viaje_seguro/model/cuidador_model.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FamiliarAceptarSolicitudesPage extends ConsumerStatefulWidget {
  const FamiliarAceptarSolicitudesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamiliarAceptarSolicitudesPageState();
}

class _FamiliarAceptarSolicitudesPageState
    extends ConsumerState<FamiliarAceptarSolicitudesPage> {
  @override
  Widget build(BuildContext context) {
    final controller = FamiliarController(ref: ref, context: context);

    final theme = ShadTheme.of(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Solicitudes de pacientes"),
        ),
        body: FutureCustomWidget(
          future:
              CuidadorController(context, ref).obtenerListaCuidador(status: 1),
          widgetBuilder: (context, snapshot) {
            final listas = snapshot.data as List<CuidadorRequestValidate>;
            return ListView.builder(
              itemCount: listas.length,
              itemBuilder: (context, index) {
                CuidadorRequestValidate request = listas[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: ShadImage.square(
                      LucideIcons.user,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    request.patient!.name.toUpperCase(),
                    style: theme.textTheme.h3.copyWith(
                      height: 0,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Su familiar es ${request.carer!.name}",
                  ),
                  onTap: () {},
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShadButton.secondary(
                        icon: const ShadImage.square(
                          LucideIcons.check,
                          size: 18,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                                title: const Text("Aceptar solicitud"),
                                content: const Text(
                                    "¿Estas seguro de aceptar la solicitud?"),
                                actions: [
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () {
                                      isBackReturn(context);
                                      controller.acceptRequest(request.id);
                                      setState(() {});
                                    },
                                    child: const Text("Aceptar"),
                                  ),
                                  CupertinoDialogAction(
                                    onPressed: () => isBackReturn(context),
                                    child: const Text("Cancelar"),
                                  ),
                                ]),
                          );
                        },
                      ),
                      ShadButton.destructive(
                        icon: const ShadImage.square(
                          LucideIcons.trash,
                          size: 18,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                                title: const Text("Aceptar solicitud"),
                                content: const Text(
                                    "¿Estas seguro de aceptar la solicitud?"),
                                actions: [
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () {
                                      isBackReturn(context);
                                      CuidadorController(context, ref)
                                          .deleteCuidador(request.id  );
                                      setState(() {});
                                    },
                                    child: const Text("Aceptar"),
                                  ),
                                  CupertinoDialogAction(
                                    onPressed: () => isBackReturn(context),
                                    child: const Text("Cancelar"),
                                  ),
                                ]),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ));
  }
}
