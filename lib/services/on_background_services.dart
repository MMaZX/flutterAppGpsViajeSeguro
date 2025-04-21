import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:app_viaje_seguro/services/location_listener_notifier.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/ws_listener_notifier.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class BackgroundInitializer {
  final ProviderContainer container;

  BackgroundInitializer(this.container);

  Future<void> initialize(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();
    log("🔵 Iniciando onStart background...");

    // Conexión WebSocket
    final wsNotifier = container.read(wsConnectionProvider.notifier);
    wsNotifier.connect();

    final completer = Completer<void>();

    bool isEnabledContainer =
        container.read(wsConnectionProvider.notifier).isConnectedBackground();
    if (isEnabledContainer) {
         completer.complete();
    }

    // Intentar reconexión periódica
    final retryTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (isEnabledContainer) {
        log("🛑 WebSocket conectado, cancelando intentos de reconexión");
        timer.cancel();
        return;
      }
      log("🔄 Reintentando conexión WebSocket...");
      container.read(wsConnectionProvider.notifier).connect();
    });

    // Esperar conexión WebSocket
    await completer.future;

    // Iniciar ubicación
    final locationStreamNotifier =
        container.read(locationStreamProvider.notifier);
    log("🟡 Ejecutando startLocationStream...");
    await locationStreamNotifier.startLocationStream();
    log("🟢 startLocationStream completado");

    // Escuchar eventos del servicio
    service.on('stopService').listen((event) async {
      await service.stopSelf();
    });

    service.on('updateNotification').listen((event) async {
      if (event == null) return;

      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin.show(
        888,
        event['title'],
        event['content'],
        NotificationDetails(
          android: EnumNotificationChannel.service.toAndroidNotificationDetails(
            ongoing: true,
          ),
        ),
      );
    });

    service.on('notificationTap').listen((event) async {
      if (event == null) return;

      final String action = event['action'] ?? '';
      if (action == 'reconnect') {
        service.invoke('requestReconnect');
      } else if (action == 'stopService') {
        await service.stopSelf();
      }
    });

    FlutterBackgroundService().on('requestReconnect').listen((_) {
      container.read(wsConnectionProvider.notifier).restart();
    });

    // Timer cada minuto para mantener activo
    Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (service is AndroidServiceInstance &&
          await service.isForegroundService()) {
        // Aquí podrías reiniciar servicios si deseas
      }
    });
  }
}
