import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreateZonaSegura extends ConsumerStatefulWidget {
  final int id;
  const CreateZonaSegura(this.id, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateZonaSeguraState();
}

class _CreateZonaSeguraState extends ConsumerState<CreateZonaSegura> {
  final decoration =
      const ShadDecoration(labelPadding: EdgeInsets.symmetric(horizontal: 7));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Crear Zona Segura"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            ShadInputFormField(
              decoration: decoration,
              label: const Text('Intervalo de Notificaciones (segundos)'),
              keyboardType: TextInputType.number,
            ),
            ShadInputFormField(
              decoration: decoration,
              label: const Text('Intervalo de Inactividad (segundos)'),
              keyboardType: TextInputType.number,
            ),
            ShadInputFormField(
              decoration: decoration,
              label: const Text('Radio de Protección (metros)'),
              keyboardType: TextInputType.number,
            ),
            ShadInputFormField(
              decoration: decoration,
              label: const Text('Lat y Log'),
              keyboardType: TextInputType.number,
            ),
            ShadSwitch(
              label: const Text("Zona Segura"),
              sublabel: const Text(
                "Activar o desactivar la configuración de la zona segura",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              value: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            ShadButton(
              onPressed: () {
                // Handle save action
              },
              child: const Text('Guardar Configuración'),
            ),
          ],
        ));
  }
}
