import 'package:app_viaje_seguro/controller/cuidador_controller.dart';
import 'package:app_viaje_seguro/model/cuidador_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:app_viaje_seguro/widgets/custom_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class InformacionListaPacientes extends ConsumerStatefulWidget {
  final DetalleDataModel paciente;
  const InformacionListaPacientes({required this.paciente, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CuidadorPageListaPacientesState();
}

class _CuidadorPageListaPacientesState
    extends ConsumerState<InformacionListaPacientes> {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final paciente = widget.paciente;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Información del paciente"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            CardCustom(
              iconData: LucideIcons.user,
              title: "Nombre",
              subtitle: paciente.name.toUpperCase(),
            ),
            CardCustom(
              iconData: LucideIcons.calendar,
              title: "Edad",
              subtitle: paciente.age.toString().toUpperCase(),
            ),
            CardCustom(
              iconData: LucideIcons.mapPin,
              title: "Dirección",
              subtitle: paciente.address,
            ),
            CardCustom(
              iconData: LucideIcons.phone,
              title: "Teléfono",
              subtitle: paciente.phone,
            ),
            CardCustom(
              iconData: LucideIcons.users,
              title: "Género",
              subtitle: paciente.genre,
            ),
          ],
        ));
  }
}
