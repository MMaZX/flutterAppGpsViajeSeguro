import 'dart:async';
import 'dart:ui';
import 'package:app_viaje_seguro/services/location_stream_notification.dart';
import 'package:app_viaje_seguro/services/web_socket_service_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Primero, creamos un proveedor para la inicialización de notificaciones
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Clase para gestionar las notificaciones
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Canales de notificación
  static const AndroidNotificationChannel serviceChannel =
      AndroidNotificationChannel(
    'channel_services_notification',
    'Notificaciones Services',
    description: 'Este canal es para notificaciones importantes del servicio.',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel reconnectionChannel =
      AndroidNotificationChannel(
    'reconnection_channel_id',
    'Reconexión WebSocket',
    description: 'Notificaciones sobre el estado de la conexión WebSocket.',
    importance: Importance.low,
  );

  static const AndroidNotificationChannel locationChannel =
      AndroidNotificationChannel(
    'location_channel_id',
    'Ubicación en Tiempo Real',
    description: 'Este canal muestra cuando la ubicación se está compartiendo.',
    importance: Importance.low,
  );

  static const AndroidNotificationChannel newRequestChannel =
      AndroidNotificationChannel(
    'new_request_channel_id',
    'Nuevas Solicitudes',
    description: 'Notificaciones sobre nuevas solicitudes entrantes.',
    importance: Importance.high,
  );

  // Inicialización de notificaciones
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Crear todos los canales de notificación
    await _createNotificationChannels();
  }

  // Método para crear los canales de notificación
  Future<void> _createNotificationChannels() async {
    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(serviceChannel);
      await androidImplementation
          .createNotificationChannel(reconnectionChannel);
      await androidImplementation.createNotificationChannel(locationChannel);
      await androidImplementation.createNotificationChannel(newRequestChannel);
    }
  }

  // Mostrar una notificación
  Future<void> showNotification({
    required int id,
    required String channelId,
    required String title,
    required String body,
    bool ongoing = false,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId.split('_').map((word) => word.capitalize()).join(' '),
          ongoing: ongoing,
        ),
      ),
    );
  }

  // Cancelar una notificación específica
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

// Extensión para capitalizar strings (útil para formatear nombres de canales)
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

// Ahora, nuestro controlador de servicio en segundo plano
final backgroundServiceControllerProvider =
    StateNotifierProvider<BackgroundServiceController, bool>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return BackgroundServiceController(notificationService);
});

class BackgroundServiceController extends StateNotifier<bool> {
  final NotificationService _notificationService;
  final FlutterBackgroundService _service = FlutterBackgroundService();

  BackgroundServiceController(this._notificationService) : super(false);

  // Inicializar todo el sistema
  Future<void> initialize() async {
    // Primero inicializamos las notificaciones

    await _notificationService.initialize();

    // Luego configuramos el servicio
    await _configureService(title: 'AlzSafe', content: 'Servicio iniciado');
    // await stopService();
    // await startService();
    print("🛫🛫🛫 SERVICIO INICIALIZADO");
  }

  // Configurar el servicio
  Future<void> _configureService(
      {required String title, required String content}) async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
        notificationChannelId: NotificationService.serviceChannel.id,
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
    final service = FlutterBackgroundService();
    if (await service.isRunning()) {
      service.invoke(
        'updateNotification',
        {
          'title': title,
          'content': content,
        },
      );
    }
  }

  // Mostrar una notificación específica
  Future<void> showCustomNotification({
    required int id,
    required String channelId,
    required String title,
    required String body,
    bool ongoing = false,
  }) async {
    await _notificationService.showNotification(
      id: id,
      channelId: channelId,
      title: title,
      body: body,
      ongoing: ongoing,
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

// Función que se ejecuta cuando el servicio en segundo plano inicia

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   // Mantiene el servicio en primer plano con una notificación persistente
//   DartPluginRegistrant.ensureInitialized();

//   // Permite recibir mensajes desde la aplicación principal
//   service.on('stopService').listen((event) async {
//     await service.stopSelf();
//   });

//   // Actualizar notificación
//   service.on('updateNotification').listen((event) async {
//     if (event == null) return;

//     // Actualizar la notificación del servicio
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();

//     await flutterLocalNotificationsPlugin.show(
//       888, // ID para la notificación del servicio
//       event['title'],
//       event['content'],
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'channel_services_notification',
//           'Notificaciones Services',
//           ongoing: true,
//         ),
//       ),
//     );
//   });

//   // Manejar el toque en la notificación
//   service.on('notificationTap').listen((event) async {
//     if (event == null) return;

//     final String action = event['action'] ?? '';

//     if (action == 'reconnect') {
//       // Notificar a la aplicación principal que debe reconectar
//       service.invoke('requestReconnect');
//     } else if (action == 'stopService') {
//       await service.stopSelf();
//     }
//   });

//   // Configurar el receptor de eventos en la aplicación principal
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     final container = ProviderContainer();
//     final wsNotifier = container.read(wsConnectionProvider.notifier);

//     FlutterBackgroundService().on('requestReconnect').listen((_) {
//       wsNotifier.forceReconnect();
//     });
//   });

//   // Aquí puedes iniciar la lógica de tu servicio
//   // Por ejemplo: WebSocket, ubicación, etc.

//   // Opcional: Notificar periódicamente sobre el estado del servicio
//   Timer.periodic(const Duration(minutes: 1), (timer) async {
//     if (service is AndroidServiceInstance) {
//       if (await service.isForegroundService()) {
//         // Puedes realizar tareas periódicas aquí
//         // ACTIVAMOS LA UBICACIÓN DEL PACIENTE SI ES QUE EXISTE EL PACIENTE MI BRO:
//         final container = ProviderContainer();
//         startLocationStreamForPaciente(container);
//       }
//     }
//   });
// }

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final container = ProviderContainer();

  // 🛑 Escucha para detener el servicio
  service.on('stopService').listen((event) async {
    await service.stopSelf();
    container
        .read(locationStreamProvider.notifier)
        .stop(); // 🔥 Parar el stream
  });

  // 🔄 Escucha para actualizar la notificación
  service.on('updateNotification').listen((event) async {
    if (event == null) return;

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.show(
      888,
      event['title'],
      event['content'],
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_services_notification',
          'Notificaciones Services',
          ongoing: true,
        ),
      ),
    );
  });

  // 👆 Manejar acciones desde la notificación
  service.on('notificationTap').listen((event) async {
    if (event == null) return;

    final String action = event['action'] ?? '';
    if (action == 'reconnect') {
      service.invoke('requestReconnect');
    } else if (action == 'stopService') {
      await service.stopSelf();
      container
          .read(locationStreamProvider.notifier)
          .stop(); // 🔥 Parar el stream
    }
  });

  // 🔁 Reconexión manual
  FlutterBackgroundService().on('requestReconnect').listen((_) {
    container.read(wsConnectionProvider.notifier).forceReconnect();
  });
  container.read(locationStreamProvider.notifier).start();

  // ✅ ⏰ Timer para chequear cada minuto
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance &&
        await service.isForegroundService()) {
      // 🚀 Iniciar el stream (si ya está corriendo, tu Notifier puede manejarlo internamente)
      // container.read(locationStreamProvider.notifier).start();
    }
  });
}
