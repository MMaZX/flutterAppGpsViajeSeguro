import 'package:app_viaje_seguro/model/pacientes_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PacientesPageDetalle extends ConsumerStatefulWidget {
  final PacientesModel pacientesModel;
  const PacientesPageDetalle({required this.pacientesModel, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PacientesPageDetalleState();
}

class _PacientesPageDetalleState extends ConsumerState<PacientesPageDetalle> {
  @override
  Widget build(BuildContext context) {
    PacientesModel paciente = widget.pacientesModel;
    final theme = ShadTheme.of(context).textTheme;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Detalles del Paciente"),
        ),
        body: ListView(
          children: [
            ListTile(
              title: Text(
                "Nombre del paciente",
                style: theme.p.copyWith(height: 0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(paciente.name),
            ),
            ListTile(
              title: Text(
                "Edad",
                style: theme.p.copyWith(height: 0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${paciente.age} años'),
            ),
            ListTile(
              title: Text(
                "Género",
                style: theme.p.copyWith(height: 0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(paciente.genre),
            ),
            ListTile(
              title: Text(
                "Teléfono",
                style: theme.p.copyWith(height: 0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(paciente.phone ?? "No disponible"),
            ),
            ListTile(
              title: Text(
                "Dirección",
                style: theme.p.copyWith(height: 0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(paciente.address ?? "No disponible"),
            ),
            ListTile(
              title: Text(
                "Relación",
                style: theme.p.copyWith(height: 0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(paciente.relation),
            ),
            ListTile(
              title: Text(
                "Estado",
                style: theme.p.copyWith(height: 0, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(paciente.status == 1 ? "Activo" : "Inactivo"),
            ),
          ],
        ));
  }
}
