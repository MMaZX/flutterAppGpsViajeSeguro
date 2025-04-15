import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/cuidador_controller.dart';
import 'package:app_viaje_seguro/model/cuidador_model.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CrearCuidadorPage extends ConsumerStatefulWidget {
  const CrearCuidadorPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CrearCuidadorPageState();
}

class _CrearCuidadorPageState extends ConsumerState<CrearCuidadorPage> {
  ShadDecoration inputDecoration =
      const ShadDecoration(labelPadding: EdgeInsets.symmetric(horizontal: 5));

  List<CuidadorModel> pacientesAll = [];
  List<CuidadorModel> pacienteOriginal = [];

  @override
  void initState() {
    // getUserCuidadores();
    super.initState();
  }

  void getUserCuidadores() async {
    try {
      pacientesAll.clear();
      final controller = CuidadorController(context, ref);
      final watch = await controller.getAllCuidador();
      setState(() {
        pacientesAll = watch;
        pacienteOriginal = watch;
      });
    } catch (e) {
      print(e);
      showDialogScope(context, ExceptionsUtils(e).toString());
    }
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      getUserCuidadores();
      _initialized = true;
    }
  }

  searchCuidadores(String query) async {
    // final allCuidadores =
    //     await CuidadorController(context, ref).getAllCuidador();
    setState(() {
      pacientesAll = pacienteOriginal.where((cuidador) {
        final lowerQuery = query.toLowerCase();
        return cuidador.name.toLowerCase().contains(lowerQuery) ||
            cuidador.phone.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  void successInvitacion(CuidadorModel paciente) async {
    showDialog(
        context: context,
        builder: (context) => DialogConfirmarPaciente(paciente));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final textTheme = theme.textTheme;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Enviar solicitud de cuidador"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              ShadInput(
                placeholder: const Text("Busca por nombres, dni o celular"),
                decoration: inputDecoration,
                onChanged: searchCuidadores,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: pacientesAll.length,
                  itemBuilder: (context, index) {
                    final paciente = pacientesAll[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text(paciente.name
                            .substring(0, 1)
                            .toString()
                            .toUpperCase()),
                      ),
                      onTap: () => successInvitacion(paciente),
                      title: Text(
                        paciente.name.toUpperCase(),
                        style: textTheme.p.copyWith(
                          height: 0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                          "Edad: ${paciente.age} | Celular: ${paciente.phone}"),
                      trailing: const ShadButton(
                          enabled: false,
                          icon:
                              ShadImage.square(LucideIcons.userPlus, size: 18)),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class DialogConfirmarPaciente extends ConsumerStatefulWidget {
  final CuidadorModel model;
  const DialogConfirmarPaciente(this.model, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogConfirmarPacienteState();
}

class _DialogConfirmarPacienteState
    extends ConsumerState<DialogConfirmarPaciente> {
  int selectedPacienteId = 0;
  List<PacienteModelValidacion> pacientes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // _loadPacientes();
  }

  Future<void> _loadPacientes() async {
    final data = await CuidadorController(context, ref).fetchPatientValidate();
    if (mounted) {
      setState(() {
        pacientes = data;
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (pacientes.isEmpty) {
      _loadPacientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final paciente = widget.model;
    return ShadDialog.alert(
      title: const Text("Enviar solicitud"),
      description: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ListView.builder(
              itemCount: pacientes.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = pacientes[index];
                final isSelected = selectedPacienteId == item.patientId;

                return Material(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.transparent,
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        selectedPacienteId = item.patientId;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      child: Text(item.name.substring(0, 1).toUpperCase()),
                    ),
                    title: Text(
                      item.name.toUpperCase(),
                      style: const TextStyle(
                        height: 0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Edad: ${item.patientId} | Relación: ${item.relation}",
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
          Text("¿Deseas enviar la solicitud al cuidador ${paciente.name}?"),
        ],
      ),
      actions: [
        ShadButton.secondary(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancelar"),
        ),
        ShadButton(
          enabled: selectedPacienteId != 0,
          onPressed: selectedPacienteId == 0
              ? null
              : () async {
                  showDialogLoading(context);
                  bool isSuccess =
                      await CuidadorController(context, ref).setInvitacion(
                    cuidadorId: int.parse(paciente.userId.toString()),
                    pacienteId: selectedPacienteId,
                  );
                  if (isSuccess) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                      (route) => false,
                    );
                  }
                },
          child: const Text("Enviar"),
        ),
      ],
    );
  }
}
