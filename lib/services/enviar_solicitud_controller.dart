import 'dart:convert';
import 'dart:developer';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/states/notifications_state.dart';
import 'package:app_viaje_seguro/services/ws_connection_provider.dart';
import 'package:app_viaje_seguro/services/ws_listener_notifier.dart';
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

    final socket = ref.read(wsConnectionProviderNotifier);

    // WebSocket connection established.
    final idUsuario = ref.read(userCredentialsProvider).id;
    if (idUsuario != 0) {
      log('ID de usuario no disponible. No se puede escuchar mensajes.');
      return;
    }

    socket.channel?.stream.listen((message) {
      // Received message from WebSocket.
      final data = jsonDecode(message);
      if (data['event'] == 'enviar-solicitud') {
        // Event "enviar-solicitud" detected.

        final Map<String, dynamic> payload = data['data'];
        final notification = NotificationsState.fromMap(payload);

        // Check if the notification is for the current user.
        if (notification.idCuidador == idUsuario) {
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
    ref.read(notificationServiceProvider).showNotification(
          id: requestNotificationId,
          channel: EnumNotificationChannel.newRequest,
          title: title,
          body: body,
          ongoing: true,
        );
  }

  /// Método para enviar una notificación al WebSocket
  Future sendNotificationToUser(
    NotificationsState notification,
  ) async {
    final channel = ref.read(wsConnectionProviderNotifier.notifier);

    final message = {
      'event': 'enviar-solicitud',
      'data': notification.toMap(),
    };
    channel.sendMessage(message);
  }
}
