import 'dart:async';
import 'dart:convert';
import 'package:app_viaje_seguro/provider/session_provider.dart';
import 'package:app_viaje_seguro/services/channel_pacientes.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/notifications_controller_services.dart';
import 'package:app_viaje_seguro/services/ws_channel_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:developer';

final wsConnectionProvider =
    StateNotifierProvider<WSConnectionNotifier, WebSocketChannel?>((ref) {
  return WSConnectionNotifier(ref);
});

class WSConnectionNotifier extends StateNotifier<WebSocketChannel?> {
  final Ref ref;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  final int _maxReconnectAttempts = 5;
  static const int reconnectionNotificationId = 99;

  WSConnectionNotifier(this.ref) : super(null);

  void connect() {
    final ipAddress = Uri.parse(ref.read(connectionProvider).ipAddress).host;
    final wsUri = Uri.parse('ws://$ipAddress:3000');

    try {
      final channel = WebSocketChannel.connect(wsUri);
      state = channel;

      _updateConnectionStatus(true, '✅ Conectado a $wsUri');
      _updateServiceNotification(
          'Servicio Activo WS', 'Conectado a $ipAddress:3000');

      _reconnectAttempt = 0;
      _cancelReconnectTimer();
      _listenToChannel(channel);

      final listener = ref.read(locationChannelListenerProvider.notifier);
      listener.startLocationUpdatesIfPaciente();
      listener.updateLocation();
    } catch (e) {
      _handleConnectionError('❌ Error al conectar al WebSocket: $e');
    }
  }

  void disconnect() {
    state?.sink.close();
    state = null;

    _updateConnectionStatus(false, '🔌 Desconectado del WebSocket');
    _updateServiceNotification(
        'Servicio WebSocket Inactivo', 'Conexión cerrada manualmente');
    _cancelReconnectTimer();
  }

  void forceReconnect() {
    state?.sink.close();
    state = null;

    _reconnectAttempt = 0;
    _cancelReconnectTimer();

    _updateServiceNotification(
        'Reiniciando Servicio WebSocket', 'Reconectando al servidor...');
    connect();
  }

  void sendMessage(Map<String, dynamic> message) {
    state?.sink.add(jsonEncode(message));
  }

  void _listenToChannel(WebSocketChannel channel) {
    channel.stream.listen((message) {
      log("📩 Mensaje recibido: $message");
      final data = jsonDecode(message);
      final listener = ref.read(locationChannelListenerProvider.notifier);
      listener.handleMessage(data);
      listener.startLocationUpdatesIfPaciente();
      ref.read(notificationControllerProvider);
    }, onError: (err) {
      _handleConnectionError("❌ Error en el WebSocket: $err");
    }, onDone: () {
      _handleConnectionError("🔌 WebSocket cerrado");
    });
  }

  void _handleConnectionError(String context) {
    _updateConnectionStatus(false, context);
    _updateServiceNotification('Error en la Conexión', context);
    _scheduleReconnect();
    _showNotification(
      id: reconnectionNotificationId,
      title: 'Conexión Perdida',
      body: 'Intentando reconectar (Intento $_reconnectAttempt)...',
      ongoing: true,
    );
  }

  void _scheduleReconnect() {
    if (_reconnectAttempt < _maxReconnectAttempts &&
        _reconnectTimer?.isActive != true) {
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        _reconnectAttempt++;
        log('🔄 Reintento #$_reconnectAttempt de $_maxReconnectAttempts');
        _updateServiceNotification('Reconectando WebSocket',
            'Intento $_reconnectAttempt de $_maxReconnectAttempts');
        connect();
      });
    } else {
      log('🛑 Máximo de reintentos alcanzado');
      _updateServiceNotification('Servicio Detenido',
          'No se pudo reconectar tras $_maxReconnectAttempts intentos. Toque para reintentar.');
      _showNotification(
        id: reconnectionNotificationId,
        title: 'Error de Conexión',
        body: 'No se pudo conectar al servidor. Toque para reintentar.',
        ongoing: false,
      );
      _restartBackgroundService();
    }
  }

  void _updateConnectionStatus(bool isConnected, String context) {
    ref.read(wsChannelStateProvider.notifier).setConnection(isConnected);
    ref.read(wsChannelStateProvider.notifier).setContext(context);
  }

  void _updateServiceNotification(String title, String content) {
    ref
        .read(backgroundServiceControllerProvider.notifier)
        .updateServiceNotification(title, content);
  }

  Future<void> _showNotification(
      {required int id,
      required String title,
      required String body,
      bool ongoing = false}) async {
    await ref
        .read(backgroundServiceControllerProvider.notifier)
        .showCustomNotification(
          id: id,
          channelId: 'reconnection_channel_id',
          title: title,
          body: body,
          ongoing: ongoing,
        );
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  Future<void> _restartBackgroundService() async {
    await ref
        .read(backgroundServiceControllerProvider.notifier)
        .restartService();
  }
}
