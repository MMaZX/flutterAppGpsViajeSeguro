import 'dart:async';

import 'package:app_viaje_seguro/provider/permission_provider.dart';
import 'package:app_viaje_seguro/services/background_services.dart';
import 'package:app_viaje_seguro/services/location_listener_notifier.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/ws_listener_notifier.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigurationServices {
  final ProviderContainer ref;
  const ConfigurationServices(this.ref);

  Future<void> initMain() async {
    //
    final notificationServices = ref.read(notificationServiceProvider);
    notificationServices.initialize(); // 1. NOTIFICACIONES

    final backgroundServices =
        ref.read(backgroundServiceControllerProvider.notifier);
    backgroundServices.initialize(); // 2. SERVICIO EN SEGUNDO PLANO
    backgroundServices.startService(); // 3. INICIA EL SERVICIO EN SEGUNDO PLANO

    final permissionHandlerServices = ref.read(permissionProvider.notifier);
    await permissionHandlerServices.checkPermission(); // 4. PERMISOS
  }

  Future<void> initOnBackground(ServiceInstance service) async {
    // 3. Inicializar y conectar el WebSocket
    // final webSocketServices = ref.read(wsConnectionProvider.notifier);
    // webSocketServices.restart();

    // 4. Iniciar la recopilación de ubicación (si es necesario)
    final locationServices = ref.read(locationStreamProvider.notifier);
    await locationServices.checkPacientesGPS();
    // Escuchar eventos del servicio
    service.on('stopService').listen((event) async {
      await service.stopSelf();
    });

    service.on('sendData').listen((event) {
      if (event == null) return;
      print('📦 Recibidito sendData con: $event');
      // Puedes guardar algo, mandar por websocket, etc.
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

    service.on('updateLocationNotification').listen((event) async {
      if (event == null) return;

      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin.show(
        889,
        event['title'] ?? 'Location Warning',
        event['content'] ?? 'No se pudo obtener la data de localización',
        NotificationDetails(
          android:
              EnumNotificationChannel.location.toAndroidNotificationDetails(
            ongoing: false,
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

    // // 5. Establecer ciclos periódicos si son necesarios
    // Timer.periodic(const Duration(seconds: 10), (timer) async {
    //   if (service is AndroidServiceInstance) {
    //     if (await service.isForegroundService()) {
    //       // Lógica adicional para tareas periódicas
    //       webSocketServices.checkConnection();
    //       locationServices.checkPacientesGPS();
    //     }
    //   }
    // });


  }
}
