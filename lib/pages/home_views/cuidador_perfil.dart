import 'package:app_viaje_seguro/model/cuidador_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CuidadorPerfil extends ConsumerStatefulWidget {
  final DetalleDataModel paciente;
  const CuidadorPerfil(this.paciente, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CuidadorPerfilState();
}

class _CuidadorPerfilState extends ConsumerState<CuidadorPerfil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perfil del cuidador"),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            height: 150,
            width: 150,
            child: const CircleAvatar(
              child: Text("SIN FOTO"),
            ),
          ),
          ListTile(
            title: const Text(
              "Edad del cuidador:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.paciente.age.toString()),
          ),
          ListTile(
            title: const Text(
              "Nombre:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.paciente.name),
          ),
          ListTile(
            title: const Text(
              "País:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.paciente.country),
          ),
          ListTile(
            title: const Text(
              "Celular:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.paciente.phone),
          ),
          ListTile(
            title: const Text(
              "Género:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.paciente.genre),
          ),
          ListTile(
            title: const Text(
              "Dirección:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(widget.paciente.address),
          ),
        ],
      ),
    );
  }
}
