import 'package:app_viaje_seguro/controller/paciente_controller.dart';
import 'package:app_viaje_seguro/model/pacientes_model.dart';
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
    final controller = PacienteController(context, ref);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pacientes"),
        actions: const [
          IconChangeTheme(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => const CrearPacientePage()));
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
                              leading: CircleAvatar(
                                child: Text(
                                  paciente.name.toUpperCase().substring(0, 1),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                paciente.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  height: 0,
                                ),
                              ),
                              subtitle: Text(paciente.phone.toString()),
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

class CrearPacientePage extends ConsumerStatefulWidget {
  const CrearPacientePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CrearPacientePageState();
}

class _CrearPacientePageState extends ConsumerState<CrearPacientePage> {
  ShadDecoration inputDecoration =
      const ShadDecoration(labelPadding: EdgeInsets.symmetric(horizontal: 5));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear pacientes"),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView(
            children: [
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Nombre del paciente"),
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Nombres del paciente"),
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Correo electrónico"),
                textInputAction: TextInputAction.next,
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Contraseña"),
              ),
            ],
          )),
          ShadButton(
            onPressed: () {
              //
            },
            width: double.maxFinite,
            child: const Flexible(child: Text("Agregar paciente")),
          )
        ],
      ),
    );
  }
}
