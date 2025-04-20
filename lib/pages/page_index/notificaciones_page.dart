import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/controller/paciente_controller.dart';
import 'package:app_viaje_seguro/model/pacientes_model.dart';
import 'package:app_viaje_seguro/model/xona_segura_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NotificacionIndexPage extends ConsumerStatefulWidget {
  const NotificacionIndexPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificacionIndexPageState();
}

class _NotificacionIndexPageState extends ConsumerState<NotificacionIndexPage> {
  bool isActiveZonaSegura = false;
  double _notificationInterval = 5.0;
  double _notificationExcededInterval = 1.0;
  double _notificationinactivoInterval = 1.0;

  @override
  Widget build(BuildContext context) {
    final watch = ref.watch(selectedNotificacionesPacienteProvider);
    final theme = ShadTheme.of(context);

    final watchNotifications = ref.watch(fetchNotificationsPacienteProvider);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Configuración de notificaciones"),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Column(
            children: [
              const SizedBox(
                  width: double.maxFinite, child: ChangePacientesByFamiliar()),
              Expanded(
                child: watch.name.isEmpty
                    ? const EmptyWidget(
                        "Selecciona un paciente para configurar su información")
                    : watchNotifications.when(
                        data: (data) {
                          if (data.latDefault == 0 && data.logDefault == 0) {
                            return const EmptyWidget(
                                "No tienes notificaciones configuradas para este paciente O no existe.");
                          }

                          if (watchNotifications.isLoading) {
                            const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView(
                            padding: const EdgeInsets.all(15),
                            children: [
                              ShadSwitch(
                                  label: Text(
                                      "Zona Segura : ${isActiveZonaSegura ? "Activado" : "Desactivado"}"),
                                  sublabel: const Text(
                                      "Activa o desactiva las alertas de la zona segura"),
                                  value: isActiveZonaSegura,
                                  onChanged: (value) {
                                    setState(() {
                                      isActiveZonaSegura = value;
                                    });
                                  }),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  "Intervalo de notificaciones (min):",
                                  style: theme.textTheme.h3.copyWith(
                                    height: 0,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Slider(
                                  value: _notificationInterval,
                                  min: 5,
                                  max: 60,
                                  divisions: 11,
                                  label: "${_notificationInterval.toInt()} min",
                                  onChanged: (value) {
                                    setState(() {
                                      _notificationInterval = value;
                                    });
                                  },
                                ),
                                trailing: Text(
                                    "${_notificationInterval.toInt()} min"),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  "Tiempo expuesto (min):",
                                  style: theme.textTheme.h3.copyWith(
                                    height: 0,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Slider(
                                  value: _notificationExcededInterval,
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  label:
                                      "${_notificationExcededInterval.toInt()} min",
                                  onChanged: (value) {
                                    setState(() {
                                      _notificationExcededInterval = value;
                                    });
                                  },
                                ),
                                trailing: Text(
                                    "${_notificationExcededInterval.toInt()} min"),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  "Tiempo de inactividad del paciente (min):",
                                  style: theme.textTheme.h3.copyWith(
                                    height: 0,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Slider(
                                  value: _notificationinactivoInterval,
                                  min: 1,
                                  max: 60,
                                  divisions: 30,
                                  label:
                                      "${_notificationinactivoInterval.toInt()} min",
                                  onChanged: (value) {
                                    setState(() {
                                      _notificationinactivoInterval = value;
                                    });
                                  },
                                ),
                                trailing: Text(
                                    "${_notificationinactivoInterval.toInt()} min"),
                              ),
                            ],
                          );
                        },
                        error: (error, stackTrace) => Column(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 50, color: Colors.red),
                            Text(
                              error.toString(),
                              style: theme.textTheme.h3.copyWith(
                                height: 0,
                                fontSize: 16,
                              ),
                            ),
                            ShadButton(
                              onPressed: () => ref
                                  .refresh(fetchNotificationsPacienteProvider),
                              child: const Text("Actualizar"),
                            ),
                          ],
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
              ),
            ],
          ),
        ));
  }
}

class ChangePacientesByFamiliar extends ConsumerStatefulWidget {
  const ChangePacientesByFamiliar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangePacientesByFamiliarState();
}

class _ChangePacientesByFamiliarState
    extends ConsumerState<ChangePacientesByFamiliar> {
  List<PacientesModel> listaPacientes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPacientes();
  }

  getPacientes() {
    final controller = PacienteController(context, ref);
    controller.getPacientes().then((value) {
      setState(() {
        listaPacientes = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final watch = ref.watch(selectedNotificacionesPacienteProvider);
    return ShadSelect<PacientesModel>(
      options: List.generate(
        listaPacientes.length,
        (index) {
          final paciente = listaPacientes[index];
          return ShadOption(
            value: paciente,
            child: Text(
              paciente.name.toUpperCase(),
            ),
          );
        },
      ),
      selectedOptionBuilder: (context, value) => Text(value.name.toUpperCase()),
      placeholder: Text(watch.name.isEmpty
          ? "Selecciona un paciente"
          : watch.name.toUpperCase()),
      onChanged: (value) {
        if (value != null) {
          ref
              .read(selectedNotificacionesPacienteProvider.notifier)
              .update((state) => value);
        }
      },
    );
  }
}

final selectedNotificacionesPacienteProvider =
    StateProvider<PacientesModel>((ref) {
  return PacientesModel.fromDefault();
});

final fetchNotificationsPacienteProvider =
    FutureProvider<ZonaSeguraModel>((ref) async {
  try {
    final api = Api(ref).dio;
    final paciente = ref.watch(selectedNotificacionesPacienteProvider);

    if (paciente.name.isEmpty) {
      return ZonaSeguraModel();
    }
    final response = await api.get(
      '/fetchNotificaciones',
      queryParameters: {
        'paciente_id': paciente.id,
      },
    );

    final data = response.data;
    final notifications = ZonaSeguraModel.fromJson(data);
    return notifications;
  } catch (e) {
    throw ExceptionsUtils(e).toString();
  }
});
