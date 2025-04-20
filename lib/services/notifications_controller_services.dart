import 'dart:convert';

import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/notifications_state.dart';
import 'package:app_viaje_seguro/services/web_socket_service_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationControllerProvider = Provider((ref) {
  return NotificationController(ref);
});

class NotificationController {
  final Ref ref;
  // ID constante para las notificaciones de solicitudes
  static const int requestNotificationId = 5;

  NotificationController(this.ref) {
    listenToSocketMessages();
  }

  void listenToSocketMessages() async {
    // Ya no necesitamos inicializar las notificaciones aquí
    // porque estamos usando el servicio centralizado

    final socket = ref.read(wsConnectionProvider);
    if (socket == null) {
      // WebSocket connection is null.
      return;
    }

    // WebSocket connection established.
    final myId = await AuthPrefs().getId();
    // Retrieved myId.

    socket.stream.listen((message) {
      // Received message from WebSocket.
      final data = jsonDecode(message);

      if (data['event'] == 'enviar-solicitud') {
        // Event "enviar-solicitud" detected.

        final Map<String, dynamic> payload = data['data'];
        final notification = NotificationsState.fromMap(payload);

        // Check if the notification is for the current user.
        if (notification.idCuidador == myId) {
          // Notification is for the current user.
          _showNotification(
            title: notification.title,
            body: notification.body,
          );
        } else {
          // Notification is not for the current user.
        }
      } else {
        // Unhandled event received.
      }
    }, onError: (error) {
      // Error in WebSocket stream.
    }, onDone: () {
      // WebSocket stream closed.
    });
  }

  Future _showNotification({
    required String title,
    required String body,
  }) async {
    // Usamos el controlador de servicio en segundo plano para mostrar la notificación
    final backgroundController =
        ref.read(backgroundServiceControllerProvider.notifier);

    await backgroundController.showCustomNotification(
      id: requestNotificationId,
      channelId:
          'new_request_channel_id', // Usamos el canal de nuevas solicitudes
      title: title,
      body: body,
      ongoing: false,
    );
  }

  /// Método para enviar una notificación al WebSocket
  Future sendNotificationToUser(
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
