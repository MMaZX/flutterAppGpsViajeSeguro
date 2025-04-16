import 'package:app_viaje_seguro/model/familiar_model.dart';
import 'package:app_viaje_seguro/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DataFamiliarPacientePage extends ConsumerStatefulWidget {
  final FamiliarModelPaciente data;
  const DataFamiliarPacientePage({required this.data, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DataFamiliarPacientePageState();
}

class _DataFamiliarPacientePageState
    extends ConsumerState<DataFamiliarPacientePage> {
  @override
  Widget build(BuildContext context) {
    DataModelFamiliar? familiar = widget.data.familiar;
    final theme = ShadTheme.of(context);
    if (familiar == null) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Ops!"),
          ),
          body: const Center(child: Text("No hay datos del familiar")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Datos del Familiar"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.accent,
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
              title: Text(familiar.name.toUpperCase(),
                  style: theme.textTheme.p.copyWith(
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
            iconData: LucideIcons.user,
            title: "Apellido",
            subtitle: familiar.lastName.toUpperCase(),
          ),
          CardCustom(
            iconData: LucideIcons.mail,
            title: "Email",
            subtitle: familiar.email,
          ),
          CardCustom(
            iconData: LucideIcons.idCard,
            title: "DNI",
            subtitle: familiar.identification,
          ),
          CardCustom(
            iconData: LucideIcons.mapPin,
            title: "País",
            subtitle: familiar.country,
          ),
          CardCustom(
            iconData: LucideIcons.map,
            title: "Dirección",
            subtitle: familiar.address,
          ),
          const Divider(),
          ListTile(
            title: Text(
              "Pacientes del familiar",
              style: theme.textTheme.h3.copyWith(
                height: 0,
                fontSize: 16,
              ),
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.data.pacientes.length,
            itemBuilder: (context, index) {
              final paciente = widget.data.pacientes[index];
              return ShadCard(
                padding: const EdgeInsets.all(10),
                title: Text(
                  paciente.name.toUpperCase(),
                  style: theme.textTheme.h3.copyWith(
                    height: 0,
                    fontSize: 16,
                  ),
                ),
                description: Text("Edad: ${paciente.age}"),
              );
            },
          )
        ],
      ),
    );
  }
}
