import 'dart:convert';
import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/services/notifications_state.dart';
import 'package:app_viaje_seguro/services/service_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationControllerProvider = Provider((ref) {
  return NotificationController(ref);
});

class NotificationController {
  final Ref ref;
  late final FlutterLocalNotificationsPlugin _notifications;

  NotificationController(this.ref) {
    _notifications = FlutterLocalNotificationsPlugin();
    _initialize();
    listenToSocketMessages();
  }

  Future<void> _initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    await _notifications.initialize(initializationSettings);
  }

  void listenToSocketMessages() async {
    final socket = ref.read(wsConnectionProvider);
    if (socket == null) {
      print('[_listenToSocketMessages] WebSocket connection is null.');
      return;
    }

    print('[_listenToSocketMessages] WebSocket connection established.');

    final myId = await AuthPrefs().getId();
    print('[_listenToSocketMessages] Retrieved myId: $myId');

    socket.stream.listen((message) {
      print('[_listenToSocketMessages] Received message: $message');
      final data = jsonDecode(message);
      print(data.toString());
      if (data['event'] == 'enviar-solicitud') {
        print('[_listenToSocketMessages] Event "enviar-solicitud" detected.');

        final Map<String, dynamic> payload = data['data'];
        final notification = NotificationsState.fromMap(payload);

        print('[_listenToSocketMessages] Notification payload: $payload');

        // Comparamos con idFamiliar porque representa al receptor
        if (notification.idCuidador == myId) {
          print(
              '[_listenToSocketMessages] Notification is for the current user.');
          _showNotification(
            title: notification.title,
            body: notification.body,
          );
        } else {
          print(
              '[_listenToSocketMessages] Notification is not for the current user.');
        }
      } else {
        print('[_listenToSocketMessages] Unhandled event: ${data['event']}');
      }
    }, onError: (error) {
      print('[_listenToSocketMessages] Error in WebSocket stream: $error');
    }, onDone: () {
      print('[_listenToSocketMessages] WebSocket stream closed.');
    });
  }

  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_services_notification',
      'Mostrar solicitudes',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notifications.show(0, title, body, notificationDetails);
  }

  /// Método para enviar una notificación al WebSocket
  Future<void> sendNotificationToUser(
    NotificationsState notification,
  ) async {
    final channel = ref.read(wsConnectionProvider);
    if (channel == null) return;

    final message = {
      'event': 'enviar-solicitud',
      'data': notification.toMap(),
    };

    channel.sink.add(jsonEncode(message));
  }
}
