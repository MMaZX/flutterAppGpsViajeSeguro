// Ahora, nuestro controlador de servicio en segundo plano
import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/on_background_services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// enum BackgroundServiceState { stopped, initializing, running, error }

final backgroundServiceControllerProvider =
    StateNotifierProvider<BackgroundServiceController, bool>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return BackgroundServiceController(ref, notificationService);
});

class BackgroundServiceController extends StateNotifier<bool> {
  final NotificationService _notificationService;
  final Ref ref;

  final FlutterBackgroundService _service = FlutterBackgroundService();

  BackgroundServiceController(this.ref, this._notificationService)
      : super(false);

  Future<bool> backgroundServiceIsRunning() async {
    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();
    if (!isRunning) {
      log("🟡 El servicio NO está corriendo. Se va a inicializar...");

      try {
        await initialize();
        await startService();
        return true; // El servicio se inició correctamente
      } catch (e) {
        log("🔴 Error al inicializar o iniciar el servicio: $e");
        return false; // Hubo un error al iniciar el servicio
      }
    } else {
      log("🟢 El servicio YA está corriendo correctamente.");
      return true; // El servicio ya estaba corriendo
    }
  }

  // Inicializar todo el sistema
  Future<void> initialize() async {
    // Primero inicializamos las notificaciones
    await _notificationService.initialize();
    // Luego configuramos el servicio
    await _configureService(title: 'AlzSafe', content: 'Servicio iniciado');
    log("🛫🛫🛫 SERVICIO INICIALIZADO");
  }

  // Configurar el servicio
  Future<void> _configureService(
      {required String title, required String content}) async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        notificationChannelId: EnumNotificationChannel.service.canalId,
        initialNotificationTitle: title,
        initialNotificationContent: content,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: (_) => true,
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

  // Reiniciar el servicio
  Future<void> restartService() async {
    await stopService();
    await startService();
  }

  // Actualizar la notificación del servicio
  Future<void> updateServiceNotification(String title, String content) async {
    // final service = FlutterBackgroundService();
    backgroundServiceIsRunning();
    _service.invoke(
      'updateNotification',
      {
        'title': title,
        'content': content,
      },
    );
  }

  // Cancelar una notificación
  Future<void> cancelNotification(int id) async {
    await _notificationService.cancelNotification(id);
  }

  // Método para solicitar una reconexión del WebSocket
  Future<void> requestWebSocketReconnect() async {
    if (await _service.isRunning()) {
      _service.invoke('requestReconnect');
    }
  }

  // Modifica el método updateServiceNotification para permitir agregar acciones
  Future<void> updateServiceNotificationAcciones(
    String title,
    String content, {
    Map<String, String>? actions,
  }) async {
    if (await _service.isRunning()) {
      _service.invoke('updateNotification', {
        'title': title,
        'content': content,
        'actions': actions,
      });
    }
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final container = ProviderContainer();
  final backgroundInit = BackgroundInitializer(container);
  await backgroundInit.initialize(service);
}
