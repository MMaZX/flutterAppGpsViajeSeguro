import 'dart:developer';

import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/controller/paciente_controller.dart';
import 'package:app_viaje_seguro/controller/zona_segura_controller.dart';
import 'package:app_viaje_seguro/model/pacientes_model.dart';
import 'package:app_viaje_seguro/model/xona_segura_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:app_viaje_seguro/pages/modal_obtener_zona.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NotificacionIndexPage extends ConsumerStatefulWidget {
  const NotificacionIndexPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotificacionIndexPageState();
}

class _NotificacionIndexPageState extends ConsumerState<NotificacionIndexPage> {
  bool isActiveZonaSegura = false;

  ZonaSeguraModel data = ZonaSeguraModel();

  Point? pointData;

  @override
  Widget build(BuildContext context) {
    final watch = ref.watch(selectedNotificacionesPacienteProvider);
    final theme = ShadTheme.of(context);

    final watchNotifications = ref.watch(fetchNotificationsPacienteProvider);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Notificaciones/Zona Segura"),
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
                child: watchNotifications.isLoading
                    ? Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(25),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Cargando notificaciones para este paciente"),
                            SizedBox(height: 10),
                            ShadProgress(),
                          ],
                        ),
                      )
                    : watch.name.isEmpty
                        ? const EmptyWidget(
                            "Selecciona un paciente para configurar su información")
                        : watchNotifications.when(
                            data: (zonaSeguraData) {
                              if (data.isEmpty) {
                                data = zonaSeguraData;
                              }

                              return RefreshIndicator(
                                onRefresh: () async => ref.invalidate(
                                    fetchNotificationsPacienteProvider),
                                child: ListView(
                                  padding: const EdgeInsets.all(15),
                                  children: [
                                    ShadCard(
                                      title: Text(
                                        "Advertencia",
                                        style: theme.textTheme.h1.copyWith(
                                          height: 0,
                                          fontSize: 16,
                                        ),
                                      ),
                                      description: Text(
                                        "Si desactivas la zona segura, no recibirás notificaciones de seguridad",
                                        style: theme.textTheme.muted.copyWith(
                                          height: 0,
                                          fontSize: 14,
                                        ),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: ShadSwitch(
                                            label: Text(
                                              "Zona Segura : ${data.isZonaSegura ? "Activado" : "Desactivado"}",
                                              style:
                                                  theme.textTheme.h1.copyWith(
                                                height: 0,
                                                color: data.isZonaSegura
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme.muted,
                                                fontSize: 16,
                                              ),
                                            ),
                                            sublabel: const Text(
                                                "Activa o desactiva las alertas de la zona segura"),
                                            value: data.isZonaSegura,
                                            onChanged: (value) {
                                              setState(() {
                                                data = data.copyWith(
                                                  isZonaSegura: value,
                                                );
                                              });
                                            }),
                                      ),
                                    ),
                                    CustomSliderTile(
                                      title:
                                          "Intervalo de notificaciones (min):",
                                      subtitle:
                                          "Tiempo entre notificaciones de seguridad en minutos.",
                                      value: data.intervaloNotificaciones,
                                      min: 0,
                                      max: 20,
                                      divisions: 20,
                                      labelBuilder: (val) =>
                                          "${val.toInt()} min",
                                      onChanged: (val) {
                                        setState(() {
                                          data = data.copyWith(
                                            intervaloNotificaciones: val,
                                          );
                                        });
                                      },
                                    ),
                                    CustomSliderTile(
                                      title: "Tiempo de inactividad (min):",
                                      subtitle:
                                          "Cuanto tiempo sin movimiento se considera inactividad, en minutos.",
                                      value: data.intervaloInactividad,
                                      min: 0,
                                      max: 20,
                                      divisions: 20,
                                      labelBuilder: (val) =>
                                          "${val.toInt()} min",
                                      onChanged: (val) {
                                        setState(() {
                                          data = data.copyWith(
                                            intervaloInactividad: val,
                                          );
                                        });
                                      },
                                    ),
                                    CustomSliderTile(
                                      title: "Radio de protección (metros):",
                                      subtitle:
                                          "Puedes moverte en un radio de ${data.radioProteccion.toInt()} metros.",
                                      value: data.radioProteccion,
                                      min: 0,
                                      max: 500,
                                      divisions: 50,
                                      labelBuilder: (val) =>
                                          "${data.radioProteccion.toInt()} m",
                                      onChanged: (val) {
                                        setState(() {
                                          data = data.copyWith(
                                            radioProteccion: val,
                                          );
                                        });
                                      },
                                    ),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () async {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              ModalObtenerZona(
                                            onPointSelected: (point) {
                                              if (point != null) {
                                                log("Ubicación seleccionada: $point");

                                                setState(() {
                                                  pointData = point;
                                                  data = data.copyWith(
                                                    latDefault: double.parse(
                                                        (point.coordinates.lat)
                                                            .toStringAsFixed(
                                                                4)),
                                                    logDefault: double.parse(
                                                        (point.coordinates.lng)
                                                            .toStringAsFixed(
                                                                4)),
                                                  );
                                                });
                                              }
                                            },
                                          ),
                                        );
                                      },
                                      child: ShadCard(
                                        backgroundColor: Colors.transparent,
                                        title: Text(
                                          pointData == null
                                              ? "Selecciona tu zona Segura"
                                              : "Zona Segura seleccionada",
                                          style: theme.textTheme.h1.copyWith(
                                            height: 0,
                                            fontSize: 16,
                                          ),
                                        ),
                                        description: Text(
                                          pointData == null
                                              ? "Selecciona la zona segura en el mapa. Dale click para abrir el mapa"
                                              : "Zona segura seleccionada: ${data.logDefault}, ${data.latDefault}",
                                          style: theme.textTheme.muted.copyWith(
                                            height: 0,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ShadButton(
                                      onPressed: () =>
                                          ZonaSeguraController(context, ref)
                                              .updateZonaSegura(data, watch.id),
                                      child: const Expanded(
                                          child: Text(
                                        "Actualizar config. zona segura",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                    )
                                  ],
                                ),
                              );
                            },
                            error: (error, stackTrace) => Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(15),
                              child: ShadCard(
                                description: Text(
                                  error.toString(),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.h3.copyWith(
                                    height: 0,
                                    fontSize: 16,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: ShadButton.outline(
                                    onPressed: () => ref.refresh(
                                        fetchNotificationsPacienteProvider),
                                    child: const Expanded(
                                        child: Text("Actualizar")),
                                  ),
                                ),
                              ),
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
      placeholder: Text(
        watch.name.isEmpty
            ? "Selecciona un paciente"
            : watch.name.toUpperCase(),
      ),
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

class CustomSliderTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) labelBuilder;
  final ValueChanged<double> onChanged;

  const CustomSliderTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.labelBuilder,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ShadCard(
        padding: const EdgeInsets.all(10),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.h4.copyWith(
                      fontSize: 15,
                      height: 0,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.muted.copyWith(
                      fontSize: 14,
                      height: 0,
                    ),
                  ),
                ],
              )),
          subtitle: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: labelBuilder(value),
            onChanged: onChanged,
          ),
          trailing: Text(labelBuilder(value)),
        ),
      ),
    );
  }
}
