// Ahora, nuestro controlador de servicio en segundo plano
import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:app_viaje_seguro/services/configuration_services.dart';
import 'package:app_viaje_seguro/services/location_listener_notifier.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/ws_connection_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// enum BackgroundServiceState { stopped, initializing, running, error }

final backgroundServiceControllerProvider =
    StateNotifierProvider<BackgroundServiceController, bool>((ref) {
  return BackgroundServiceController(ref);
});

class BackgroundServiceController extends StateNotifier<bool> {
  // final NotificationService _notificationService;
  final Ref ref;

  final FlutterBackgroundService _service = FlutterBackgroundService();

  BackgroundServiceController(this.ref) : super(false);

  // Inicializar el servicio

  // Inicializar todo el sistema
  Future<void> initialize() async {
    await _configureService(title: 'AlzSafe', content: 'Servicio iniciado');
  }

  // Configurar el servicio
  Future<void> _configureService(
      {required String title, required String content}) async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        onStart: onStart,
        isForegroundMode: true,
        autoStartOnBoot: true,
        notificationChannelId: EnumNotificationChannel.service.canalId,
        initialNotificationTitle: title,
        initialNotificationContent: content,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        // onForeground: onStart,
        onBackground: (service) => true,
      ),
    );
  }

  // Iniciar el servicio
  Future<void> startService() async {
    await _service.startService();
    state = true;
  }

  // Detener el servicio
  Future<void> stopService() async {
    _service.invoke('stopService');
    state = false;
  }

  // Actualizar la notificación del servicio
  Future<void> updateServiceNotification(String title, String content) async {
    try {
      _service.invoke(
        'updateNotification',
        {
          'title': title,
          'content': content,
        },
      );
    } catch (e) {
      throw Exception("CATCH UPDATE SERVICES NOTIFICATION: $e");
    }
  }

  Future<void> refreshBackground() async {
    try {
      _service.invoke('refreshData', <String, dynamic>{});
      print('✅ Mensaje refreshData enviado al background');
    } catch (e) {
      print('❌ Error enviando refreshData: $e');
    }
  }

  // Actualizar la notificación del servicio con información de ubicación
  Future<void> updateLocationNotification(String title, String content) async {
    try {
      final data = {
        'title': title,
        'content': content,
      };
      _service.invoke(
        'updateLocationNotification',
        data,
      );
    } catch (e) {
      throw Exception("CATCH UPDATE LOCATION NOTIFICATION: $e");
    }
  }

  // Cancelar una notificación
  Future<void> cancelNotification(int id) async {
    final notificationService = ref.watch(notificationServiceProvider);
    await notificationService.cancelNotification(id);
  }

  // Método para solicitar una reconexión del WebSocket
  Future<void> requestWebSocketReconnect() async {
    _service.invoke('requestReconnect');
    // if (await _service.isRunning()) {
    // }
  }

  // Modifica el método updateServiceNotification para permitir agregar acciones
  Future<void> updateServiceNotificationAcciones(
    String title,
    String content, {
    Map<String, String>? actions,
  }) async {
    _service.invoke('updateNotification', {
      'title': title,
      'content': content,
      'actions': actions,
    });
    // if (await _service.isRunning()) {
    // }
  }
}

class BackgroundServices {
  final service = FlutterBackgroundService();

  Future<bool> checkServiceRunning() async {
    return await service.isRunning();
  }

  Future<void> setBackground() async {
    if (await service.isRunning()) {
      service.invoke(InvokeServiceField.background);
    } else {
      log("El servicio no está corriendo (setBackground)");
    }
  }

  Future<void> setForeground() async {
    if (await service.isRunning()) {
      service.invoke(InvokeServiceField.foreground);
    } else {
      log("El servicio no está corriendo (setForeground)");
    }
  }

  Future<void> restartGPSconnection() async {
    if (await service.isRunning()) {
      service.invoke(InvokeServiceField.restartConnectionGps);
    } else {
      log("El servicio no está corriendo (stopService)");
    }
  }

  // Actualizar la notificación del servicio con información de ubicación
  Future<void> updateLocationNotification(String title, String content) async {
    final data = {'title': title, 'content': content};
    try {
      service.invoke(InvokeServiceField.updateNotificationWSConnection, data);
    } catch (e, stackTrace) {
      log("Error updating location notification: $e", stackTrace: stackTrace);
      rethrow;
    }
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  final provider = ProviderContainer();
  final ws = provider.read(wsConnectionProviderNotifier.notifier);

  provider.read(locationStreamProvider.notifier).startLocationStream();

  if (service is AndroidServiceInstance) {
    service.on(InvokeServiceField.foreground).listen((event) {
      log("ESTAMOS EN MODO FOREGROUND");
      service.setAsForegroundService();
      ws.checkConnection();
    });

    service.on(InvokeServiceField.background).listen((event) {
      log("ESTAMOS EN MODO BACKGROUND");
      service.setAsBackgroundService();
      ws.checkConnection();
    });
  }

  // CON ESTE SERVICIO LO MATAMOS AL SERVICIO
  service.on(InvokeServiceField.stopService).listen((event) async {
    await service.stopSelf();
  });

// CON ESTE ACTUALIZAMOS LA NOTIFICACIÓN DE LA UBICACIÓN
  service
      .on(InvokeServiceField.updateNotificationWSConnection)
      .listen((event) async {
    if (event == null) return;
    final notificationServices = NotificationService();
    notificationServices.showNotification(
      id: 130,
      channel: EnumNotificationChannel.location,
      title: event['title'],
      body: event['content'],
      ongoing: true,
      priority: Priority.low,
    );
  });

  service.on(InvokeServiceField.updateOnTapNotification).listen((event) async {
    if (event == null) return;
    final String action = event['action'] ?? '';
    if (action == 'reconnect') {
      ws.checkConnection();
    } else if (action == 'stopService') {
      await service.stopSelf();
    }
  });

  service.on(InvokeServiceField.restartConnectionGps).listen((event) async {
    if (event == null) return;
    BackgroundServices().updateLocationNotification(
      "Reiniciando Ubicación",
      "Se está reiniciando el servicio de localización",
    );
    provider.invalidate(locationStreamProvider);
    provider.read(locationStreamProvider.notifier).startLocationStream();
  });

  // 5. Establecer ciclos periódicos si son necesarios
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        // ACTIVIDADES EN MODO FOREGROUND OSEA EN SEGUNDO PLANO
        // webSocketServices.checkConnection();
        // locationServices.checkPacientesGPS();
      }

      // print("Hello world! INVOKED UPDATE SERVICE");
      // service.invoke(InvokeServiceField.updateService);
    }
  });
}

class InvokeServiceField {
  static String foreground = 'setAsForeground';
  static String background = 'setAsBackground';
  static String stopService = 'stopService';
  static String updateService = 'update';
  static String updateNotificationWSConnection =
      'updateConnectionWSNotification';
  static String updateOnTapNotification = 'updateOnTapNotification';
  static String restartConnectionGps = 'restartConnectionGps';
}

  // final notificationService = provider.read(notificationServiceProvider);
  // await notificationService.initialize();

  // // Listener para refrescar todo el estado del isolate
  // service.on('refreshData').listen((event) async {
  //   print('🔄 Refreshing background isolate');
  //   final config = ConfigurationServices(provider);
  //   await config.initOnBackground(
  //       service); // o bien invoca sólo tu lógica de reconfiguración
  // });

  // final config = ConfigurationServices(provider);
  // await config.initOnBackground(service);