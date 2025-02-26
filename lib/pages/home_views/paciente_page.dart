import 'package:app_viaje_seguro/pages/constants.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pacientes"),
        actions: const [
          IconChangeTheme(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, CupertinoPageRoute(builder: (context) => const CrearPacientePage()));
        },
        child: const ShadImage.square(LucideIcons.userPlus, size: 24),
      ),
      body: Column(
        children: [
          Expanded(
            child: listaPacientes.isEmpty
                ? const EmptyWidget(
                    "No tienes algún paciente agregado, puedes agregar uno.")
                : ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const CircleAvatar(),
                        title: Text(
                          "Paciente ${index + 1}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            height: 0,
                          ),
                        ),
                        subtitle: Text("Familia ${index + 1}"),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}

class CrearPacientePage extends ConsumerStatefulWidget {
  
  const CrearPacientePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CrearPacientePageState();
}

class _CrearPacientePageState extends ConsumerState<CrearPacientePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear pacientes"),
      ),
      body: Column(
        children: [
          //
        ],
      ),
    );
  }
}
