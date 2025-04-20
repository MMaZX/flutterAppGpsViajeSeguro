import 'package:app_viaje_seguro/model/pacientes_model.dart';
import 'package:app_viaje_seguro/pages/zona_segura/create_zona_segura.dart';
import 'package:app_viaje_seguro/widgets/custom_widgets.dart';
import 'package:flutter/cupertino.dart';
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
    final themeApp = ShadTheme.of(context);
    final theme = ShadTheme.of(context).textTheme;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Detalles del Paciente"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    themeApp.colorScheme.primary,
                    themeApp.colorScheme.accent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                ),
              ),
              // height: 150,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 20,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const ShadImage.square(
                    LucideIcons.user,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                title: Text(paciente.name.toUpperCase(),
                    style: theme.p.copyWith(
                      height: 0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ShadBadge(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Text("Activo"),
                    ),
                  ],
                ),
              ),
            ),
            CardCustom(
                iconData: LucideIcons.calendar,
                title: "Edad",
                subtitle: "${paciente.age} años"),
            CardCustom(
                iconData: LucideIcons.users,
                title: "Género",
                subtitle: paciente.genre),
            CardCustom(
                iconData: LucideIcons.phoneCall,
                title: "Celular",
                subtitle: paciente.phone ?? "No disponible"),
            CardCustom(
                iconData: LucideIcons.map,
                title: "Dirección",
                subtitle: paciente.address ?? "No disponible"),
            CardCustom(
                iconData: LucideIcons.heart,
                title: "Relación",
                subtitle: paciente.relation),
            CardCustom(
                iconData: LucideIcons.shieldCheck,
                title: "Estado",
                subtitle: paciente.status == 1 ? "Activo" : "Inactivo"),
            ShadButton(
              onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => CreateZonaSegura(paciente.userId),
                  )),
              child: const Text("Configurar ZONA SEGURA"),
            ),
          ],
        ));
  }
}
