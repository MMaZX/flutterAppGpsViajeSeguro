import 'package:app_viaje_seguro/controller/cuidador_controller.dart';
import 'package:app_viaje_seguro/model/cuidador_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
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
          children: [
            ListTile(
              title: const Text("Nombre"),
              subtitle: Text(paciente.name.toUpperCase()),
            ),
            ListTile(
              title: const Text("Edad"),
              subtitle: Text(paciente.age.toString().toUpperCase()),
            ),
            ListTile(
              title: const Text("Dirección"),
              subtitle: Text(paciente.address),
            ),
            ListTile(
              title: const Text("Teléfono"),
              subtitle: Text(paciente.phone),
            ),
            ListTile(
              title: const Text("Genero"),
              subtitle: Text(paciente.genre),
            ),
          ],
        ));
  }
}
