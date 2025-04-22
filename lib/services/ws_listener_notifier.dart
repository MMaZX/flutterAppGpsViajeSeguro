import 'dart:async';
import 'dart:convert';
import 'package:app_viaje_seguro/mapas/eventos/paciente_location_evento.dart';
import 'package:app_viaje_seguro/mapas/eventos/paciente_notifier_evento.dart';
import 'package:app_viaje_seguro/provider/session_provider.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:app_viaje_seguro/services/background_services.dart';
import 'package:app_viaje_seguro/services/location_listener_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:developer';
import 'package:web_socket_channel/status.dart' as status;

/// Provider global para manejar el estado de conexión WebSocket
final wsConnectionProvider =
    StateNotifierProvider<WSConnectionNotifier, WebSocketChannel?>((ref) {
  return WSConnectionNotifier(ref);
});

/// Notificador que maneja la conexión WebSocket y su estado
class WSConnectionNotifier extends StateNotifier<WebSocketChannel?> {
  final Ref ref;
  WSConnectionNotifier(this.ref) : super(null) {
    if (isConnected) {
      updateNotification(
          "Conexión WebSocket", "Conexión WebSocket ya establecida.");
    }
  }

  // VARIABLES CONEXIÓN
  Timer? temporizadorReconexion;
  Timer? temporizadorTiempoConexion;
  int intentoReconexion = 0;
  int maximosIntentosReconexion = 5;
  int segundosTiempoConexion = 5;
  static const int idNotificacionReconexion = 99;

  // Estados de conexión
  bool isConnected = false;

  /// Indica si hay una conexión activa en segundo plano
  bool get isEnabled => isConnected;

  void connect() async {
    log("✔️ Iniciando conexión WebSocket...");

    // Si ya hay una conexión activa, ciérrala antes de continuar
    if (state != null) {
      log("🔁 Ya existe una instancia WebSocket, cerrando conexión previa...");
      try {
        // await state?.sink
        //     .close(status.goingAway); // Cierra con código de salida limpio
        state?.sink.close();
      } catch (e) {
        log("❌ Error al cerrar la conexión existente: $e");
      }
      state = null;
      isConnected = false;
      _closeTimers();
    }

    try {
      final ipAddress = Uri.parse(ref.read(connectionProvider).ipAddress).host;
      final wsUri = Uri.parse('ws://$ipAddress:3000');
      log("🔌 Intentando conectar a: $wsUri");

      final channel = WebSocketChannel.connect(wsUri);
      state = channel;

      try {
        await channel.ready;
        String message = "Conexión WebSocket establecida correctamente. $wsUri";
        createNotification("Conexión WebSocket", message);
        _updateStateNotifier(channel, message, true);
      } catch (e) {
        log("❌ Error al esperar la conexión: $e");
        isConnected = false;
        _updateStateNotifier(
            null, "🔴 Error al establecer la conexión: $e", false);
        return;
      }

      channel.stream.listen(
        (message) {
          try {
            final decoded = jsonDecode(message);
            final event = decoded['event'];

            if (event == 'patient-location-update' &&
                ref.watch(userCredentialsProvider).tipoRol.toLowerCase() !=
                    "paciente") {
              final location = PatientLocation.fromJson(decoded);
              ref
                  .read(patientLocationsProvider.notifier)
                  .updateLocation(location);
            }

            _updateStateNotifier(channel, "Conexión WebSocket activa", true);
            log("📩 Mensaje recibido: $message");
          } catch (e) {
            log("❌ Error procesando mensaje WS: $e");
          }
        },
        onError: (error) {
          _updateStateNotifier(
              null, "🔴 Error en la conexión WebSocket: $error", false);
          _closeTimers();
        },
        cancelOnError: true,
      );
    } catch (e) {
      log("❌ No se puede conectar un WS: $e");
      state = null;
    }
  }

  void disconnect() {
    _closeTimers();
    state?.sink.close();
    // state?.sink.close(status.goingAway);
    _updateStateNotifier(null, "🔌 Desconectando WebSocket...", false);
  }

  void restart() {
    log("🔄 Reiniciando WebSocket...");
    disconnect();
    Future.delayed(const Duration(milliseconds: 500), () {
      connect();
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    try {
      // print(isConnected);
      if (!isConnected) {
        log("⚠️ Intento de enviar mensaje sin conexión activa: $message");
        throw Exception(
            "La conexión del WS no está activa. No se puede enviar el mensaje. OPERACIÓN CANCELADA");
      }
      final jsonString = jsonEncode(message);
      log("📤 Enviando mensaje: $jsonString");
      state?.sink.add(jsonString);
    } catch (e) {
      log("❌ Error al enviar mensaje: $e",
          error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  void createNotification(String title, String content) {
    _showNotification(title, content);
  }

  /// Actualiza la notificación del servicio en segundo plano
  void updateNotification(String title, String content) {
    _showNotification(title, content);
  }

  void _showNotification(String title, String content) async {
    try {
      final controller = ref.read(backgroundServiceControllerProvider.notifier);
      await controller.updateServiceNotification(title, content);
    } catch (e) {
      log("❌ NO SE PUDO ACTIVAR LA NOTIFICACIÓN DE WS: $e",
          error: e, stackTrace: StackTrace.current);
    }
  }

  void _closeTimers() {
    log("⏹️ Cancelando timers...");
    temporizadorReconexion?.cancel();
    temporizadorTiempoConexion?.cancel();
    temporizadorReconexion = null;
    temporizadorTiempoConexion = null;
  }

  void _updateStateNotifier(
      WebSocketChannel? canal, String message, bool conected) {
    isConnected = conected;
    state = canal;
    log("[update] $message");
  }

  void checkConnection() {
    // log("❓ Verificando estado de conexión: $isConnected");
    if (!isConnected) {
      log("⚠️ No hay conexión activa, intentando reconectar...");
      _reconnectWebSocket();
    } else {
      debugPrint("✅ La conexión WebSocket ya existe y está activa.");
    }
  }

  void restartConnectionGps() async {
    // 3. Iniciar la recopilación de ubicación (si es necesario)
    final locationServices = ref.read(locationStreamProvider.notifier);
    await locationServices.startLocationStream();
  }

  /// Intenta reconectar el WebSocket con un retardo.
  void _reconnectWebSocket() {
    if (temporizadorReconexion == null || !temporizadorReconexion!.isActive) {
      temporizadorReconexion =
          Timer(Duration(seconds: segundosTiempoConexion), () {
        log("🔄 Intentando reconectar WebSocket...");
        connect();
        restartConnectionGps();
      });
    } else {
      log("⏳ Reintento de conexión ya programado.");
    }
  }
}
