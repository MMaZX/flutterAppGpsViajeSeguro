// Ahora, nuestro controlador de servicio en segundo plano
import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:app_viaje_seguro/services/configuration_services.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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

  // Inicializar todo el sistema
  Future<void> initialize() async {
    final notificationService = ref.watch(notificationServiceProvider);
    // Primero inicializamos las notificaciones
    await notificationService.initialize();
    // Luego configuramos el servicio
    await _configureService(title: 'AlzSafe', content: 'Servicio iniciado');
    log("🛫🛫🛫 SERVICIO INICIALIZADO");
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

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  //
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final provider = ProviderContainer();

  final notificationService = provider.read(notificationServiceProvider);
  await notificationService.initialize();


  // Listener para refrescar TODO el estado del isolate
  service.on('refreshData').listen((event) async {
    print('🔄 Refreshing background isolate');
    final config = ConfigurationServices(provider);
    await config.initOnBackground(
        service); // o bien invoca sólo tu lógica de reconfiguración
  });

  final config = ConfigurationServices(provider);
  await config.initOnBackground(service);
}

// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();

//   return true;
// }
