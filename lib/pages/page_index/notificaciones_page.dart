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
    final theme = ShadTheme.of(context);
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
        body: ListView(
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
              trailing: Text("${_notificationInterval.toInt()} min"),
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
                label: "${_notificationExcededInterval.toInt()} min",
                onChanged: (value) {
                  setState(() {
                    _notificationExcededInterval = value;
                  });
                },
              ),
              trailing: Text("${_notificationExcededInterval.toInt()} min"),
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
                label: "${_notificationinactivoInterval.toInt()} min",
                onChanged: (value) {
                  setState(() {
                    _notificationinactivoInterval = value;
                  });
                },
              ),
              trailing: Text("${_notificationinactivoInterval.toInt()} min"),
            ),
          ],
        ));
  }
}
