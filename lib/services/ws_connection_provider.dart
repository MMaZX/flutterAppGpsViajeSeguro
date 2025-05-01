import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:app_viaje_seguro/mapas/eventos/paciente_location_evento.dart';
import 'package:app_viaje_seguro/mapas/eventos/paciente_notifier_evento.dart';
import 'package:app_viaje_seguro/provider/session_provider.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/states/notifications_state.dart';
import 'package:app_viaje_seguro/services/states/ws_channel_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final wsConnectionProviderNotifier =
    StateNotifierProvider<WebSocketNotifier, WsConnectionState>(
  (ref) => WebSocketNotifier(ref),
);

class WebSocketNotifier extends StateNotifier<WsConnectionState> {
  final Ref ref;
  WebSocketNotifier(this.ref)
      : super(const WsConnectionState(status: WebSocketStatus.disconnected));

  final NotificationService _notificationService = NotificationService();

  WebSocketChannel? _socket;
  bool _isTryingToConnect = false;

  Future<bool> connect({int retry = 0}) async {
    if (_isTryingToConnect) return false;

    final rol = await ref.read(userCredentialsProvider.notifier).getRol();

    _isTryingToConnect = true;
    state = state.copyWith(
      channel: null,
      status: WebSocketStatus.connecting,
      message: "Conectando",
    );
    _sendNotificationWS("Reconectando", state.message);

    try {
      final ipAddress = Uri.parse(ref.read(connectionProvider).ipAddress).host;
      final wsUri = Uri.parse('ws://$ipAddress:5000');
      _socket = WebSocketChannel.connect(wsUri);

      await _socket?.ready.then((_) {
        state = state.copyWith(
          channel: _socket,
          status: WebSocketStatus.connected,
          message: "Conectado al servidor WebSocket en $wsUri",
        );
        _sendNotificationWS("Conexión exitosa", state.message);
      }).catchError((e) {
        state = state.copyWith(
          channel: null,
          status: WebSocketStatus.error,
          message: e.toString(),
        );
        _sendNotificationWS("Error al momento de conexión", state.message);
      });
      _socket!.stream.listen(
        (data) {
          // print('Mensaje recibido: $data');
          // TE DA LA UBICACIÓN DE TUS PACIENTES
          explorePatientUbication(data, rol);
          // TE DA LA SOLCIITUD DE TUS PACIENTES SI SOLO SI ERES CUIDADOR
          exploreSolicitudPatient(data);
        },
        onDone: () {
          state = state.copyWith(status: WebSocketStatus.disconnected);
          reconnect();
        },
        onError: (e) {
          state = state.copyWith(
              status: WebSocketStatus.error, message: e.toString());
          reconnect();
        },
      );

      _isTryingToConnect = false;
      return true;
    } catch (e) {
      state = state.copyWith(
        channel: null,
        status: WebSocketStatus.error,
        message: e.toString(),
      );
      _isTryingToConnect = false;
      _sendNotificationWS("Conexión Fallida", state.message);
      await Future.delayed(Duration(seconds: 2 * (retry + 1)));
      return connect(retry: retry + 1);
    }
  }

  void reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (state.status != WebSocketStatus.connected) {
        connect();
      }
    });
  }

  void disconnect() {
    state.channel?.sink.close();
    state = state.copyWith(
      channel: null,
      status: WebSocketStatus.disconnected,
      message: "Desconectado",
    );
    _sendNotificationWS("Desconexión WS", state.message);
  }

  void sendMessage(Map<String, dynamic> message) {
    if (state.channel != null && state.status == WebSocketStatus.connected) {
      final jsonString = jsonEncode(message);
      log("📤 Enviando mensaje: $jsonString");
      state.channel?.sink.add(jsonString);
    } else {
      throw Exception(
          "No se puede enviar el mensaje, WebSocket no está conectado.");
    }
  }

  void checkConnection() {
    print("Verificando conexión WebSocket...");
    if (state.status != WebSocketStatus.connected && !_isTryingToConnect) {
      connect();
    }
  }

  void explorePatientUbication(message, String rol) {
    try {
      final decoded = jsonDecode(message);
      final event = decoded['event'];

      // Verificar que el evento sea el esperado
      if (event == 'patient-location-update' &&
          rol.toLowerCase() != "paciente") {
        final location = PatientLocation.fromJson(decoded);
        ref.read(patientLocationsProvider.notifier).updateLocation(location);
      } else {
        log("Posiblemente rol desconocido: $event");
      }
    } catch (e) {
      log("Error al procesar el mensaje WebSocket: $e");
    }
  }

  void exploreSolicitudPatient(message) {
    try {
      final decoded = jsonDecode(message);
      final event = decoded['event'];
      int idUsuario = ref.read(userCredentialsProvider).id;

      if (event == 'enviar-solicitud') {
        // Event "enviar-solicitud" detected.

        final Map<String, dynamic> payload = decoded['data'];
        final notification = NotificationsState.fromMap(payload);

        // Check if the notification is for the current user.
        if (notification.idCuidador == idUsuario) {
          // Notification is for the current user.
          _sendNotificationCuidadorPatient(
            notification.title,
            notification.body,
          );
        } else {
          // Notification is not for the current user.
          log("Este mensaje no es para el usuario actual: $idUsuario");
        }
      }
    } catch (e) {
      log("Error al procesar la solicitud de envio: $e");
    }
  }

  // Función para actualizar la notificación
  void _sendNotificationWS(String title, String body) {
    // Aquí puedes pasar el canal que consideres adecuado para la notificación
    _notificationService.showNotification(
      id: 129, // 129 PORQUE ES EL ID DEL SERVICIO EN SEGUNDO PLANO
      channel: EnumNotificationChannel.reconnection,
      title: title,
      body: body,
    );
  }

  void _sendNotificationCuidadorPatient(String title, String body) {
    _notificationService.showNotification(
      id: 131,
      channel: EnumNotificationChannel.newRequest,
      title: title,
      body: body,
      ongoing: true,
    );
  }
}
