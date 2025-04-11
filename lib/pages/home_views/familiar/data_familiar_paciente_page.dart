import 'package:app_viaje_seguro/model/familiar_model.dart';
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
        children: [
          ListTile(
            title: const Text("Nombre"),
            subtitle: Text(familiar.name.toUpperCase()),
          ),
          ListTile(
            title: const Text("Apellido"),
            subtitle: Text(familiar.lastName.toUpperCase()),
          ),
          ListTile(
            title: const Text("Email"),
            subtitle: Text(familiar.email),
          ),
          ListTile(
            title: const Text("DNI"),
            subtitle: Text(familiar.identification),
          ),
          ListTile(
            title: const Text("País"),
            subtitle: Text(familiar.country),
          ),
          ListTile(
            title: const Text("Dirección"),
            subtitle: Text(familiar.address),
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
