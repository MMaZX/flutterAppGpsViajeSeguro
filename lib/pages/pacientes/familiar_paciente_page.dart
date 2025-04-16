import 'package:app_viaje_seguro/controller/paciente_controller.dart';
import 'package:app_viaje_seguro/model/cuidador_model_data.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:app_viaje_seguro/widgets/custom_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FamiliarPacientePage extends ConsumerStatefulWidget {
  const FamiliarPacientePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FamiliarPacientePageState();
}

class _FamiliarPacientePageState extends ConsumerState<FamiliarPacientePage> {
  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Familiar del Paciente'),
        ),
        body: FutureCustomWidget(
            future: PacienteController(context, ref).fetchFamiliar(),
            widgetBuilder: (context, snapshot) {
              List<DataFormModelPage> list = snapshot.data;
              if (list.isEmpty) {
                return const EmptyWidget(
                    "No se encontraron familiares asociados");
              }
              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final data = list[index];
                  return ShadCard(
                    title: Text(
                      data.name.toUpperCase(),
                      style: textTheme.h3.copyWith(
                        height: 0,
                        fontSize: 16,
                      ),
                    ),
                    description: Text(data.email),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        CardCustom(
                          iconData: LucideIcons.users,
                          title: "Relación",
                          subtitle: data.relation,
                        ),
                        CardCustom(
                          iconData: Icons.email,
                          title: "Correo",
                          subtitle: data.email,
                        ),
                        CardCustom(
                          iconData: LucideIcons.construction,
                          title: "País",
                          subtitle: data.country,
                        ),
                        CardCustom(
                          iconData: LucideIcons.shieldCheck,
                          title: "Estado",
                          subtitle: data.status,
                        ),
                      ],
                    ),
                  );
                },
              );
            }));
  }
}
