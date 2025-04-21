import 'dart:async';
import 'dart:convert';
import 'package:app_viaje_seguro/provider/session_provider.dart';
import 'package:app_viaje_seguro/services/background_services.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:developer';

/// Provider global para manejar el estado de conexión WebSocket
final wsConnectionProvider =
    StateNotifierProvider<WSConnectionNotifier, WebSocketChannel?>((ref) {
  return WSConnectionNotifier(ref);
});

/// Notificador que maneja la conexión WebSocket y su estado
class WSConnectionNotifier extends StateNotifier<WebSocketChannel?> {
  final Ref ref;
  Timer? _reconnectTimer;
  Timer? _connectionTimeoutTimer;
  int _reconnectAttempt = 0;
  final int _maxReconnectAttempts = 5;
  final int _connectionTimeoutSeconds = 5;
  static const int _reconnectionNotificationId = 99;

  // Estados de conexión
  bool _isConnected = false;

  /// Constructor
  WSConnectionNotifier(this.ref) : super(null);

  /// Indica si hay una conexión activa en segundo plano
  bool isConnectedBackground() => _isConnected;

  /// Inicia la conexión WebSocket al servidor
  void connect() {
    log("🔄 Iniciando conexión WebSocket...");


    _cancelTimers();

    try {
      // Obtener la dirección IP del servidor desde el provider
      final ipAddress = Uri.parse(ref.read(connectionProvider).ipAddress).host;
      final wsUri = Uri.parse('ws://$ipAddress:3000');

      log("🔌 Intentando conectar a: $wsUri");

      // Intentar notificar, pero manejar posibles errores
      _safeUpdateNotification(
          'Conectando...', 'Estableciendo conexión a $ipAddress:3000');

      // Intentar establecer la conexión
      final channel = WebSocketChannel.connect(wsUri);
      state = channel;

      // Establecer un timer de timeout para detectar si la conexión falla
      _connectionTimeoutTimer =
          Timer(Duration(seconds: _connectionTimeoutSeconds), () {
        if (!_isConnected) {
          log("⏱️ Timeout: No se pudo establecer conexión en $_connectionTimeoutSeconds segundos");
          _handleConnectionError('❌ Conexión al WebSocket falló por timeout');

          // Cerrar el canal si existe pero no se completó la conexión
          state?.sink.close();
          state = null;
        }
      });

      // Configurar el listener para el stream cuando esté disponible
      channel.ready.then((_) {
        log("✅ Canal WebSocket listo, configurando listeners");
        _updateConnectionStatus(true, '✅ Conectado a $wsUri');

        // Intentar notificar, pero manejar posibles errores
        _safeUpdateNotification(
            'Conexión al servidor', 'Conectado a $ipAddress:3000');

        _reconnectAttempt = 0;
        _cancelTimers();
        _listenToChannel(channel);
      }).catchError((error) {
        log("❌ Error al inicializar canal: $error",
            error: error, stackTrace: StackTrace.current);
        _handleConnectionError(
            '❌ Error al inicializar canal WebSocket: $error');
      });
    } catch (e) {
      log("❌ Excepción al intentar conectar: $e",
          error: e, stackTrace: StackTrace.current);
      _handleConnectionError('❌ Error al intentar conectar al WebSocket: $e');
      state = null;
    }
  }

  /// Desconecta manualmente el WebSocket
  void disconnect() {
    log("🔌 Desconectando WebSocket manualmente");

    if (state != null) {
      state?.sink.close();
      state = null;
    }

    _updateConnectionStatus(false, '🔌 Desconectado del WebSocket manualmente');
    _safeUpdateNotification(
        'Servicio WebSocket Inactivo', 'Conexión cerrada manualmente');
    _cancelTimers();
  }

  /// Fuerza una reconexión del WebSocket
  void restart() {
    log("🔄 Forzando reconexión del WebSocket");

    // Cerrar conexión actual si existe
    if (state != null) {
      state?.sink.close();
      state = null;
    }

    // Resetear el contador de intentos de reconexión
    _reconnectAttempt = 0;
    _cancelTimers();

    _safeUpdateNotification(
        'Reiniciando Servicio WebSocket', 'Reconectando al servidor...');

    // Pequeña pausa antes de reconectar para evitar problemas
    Timer(Duration(milliseconds: 500), () {
      connect();
    });
  }

  /// Envía un evento a través del WebSocket
  void sendMessage(Map<String, dynamic> message) {
    if (state == null || !_isConnected) {
      log("⚠️ Intento de enviar mensaje sin conexión activa: $message");
      return;
    }

    try {
      final jsonString = jsonEncode(message);
      log("📤 Enviando mensaje: $jsonString");
      state?.sink.add(jsonString);
    } catch (e) {
      log("❌ Error al enviar mensaje: $e",
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Crea una notificación para el servicio en segundo plano
  void createNotification(String title, String content) {
    _safeUpdateNotification(title, content);
  }

  /// Actualiza la notificación del servicio en segundo plano
  void updateNotification(String title, String content) {
    _safeUpdateNotification(title, content);
  }

  /// Crea una notificación para que el usuario pueda reconectar manualmente
  Future<void> createReconnectionNotification(
      {required String title,
      required String body,
      bool ongoing = false}) async {
    try {
      await ref.read(notificationServiceProvider).showNotification(
          id: _reconnectionNotificationId,
          channel: EnumNotificationChannel.reconnection,
          title: title,
          body: body,
          ongoing: ongoing,
          actions: [
            const AndroidNotificationAction(
                'reconnect_now', 'Reconectar Ahora'),
          ]);
    } catch (e) {
      log("❌ Error al crear notificación de reconexión: $e",
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Actualiza la notificación de reconexión
  Future<void> updateReconnectionNotification(
      {required String title,
      required String body,
      bool ongoing = false}) async {
    try {
      await ref.read(notificationServiceProvider).showNotification(
          id: _reconnectionNotificationId,
          channel: EnumNotificationChannel.reconnection,
          title: title,
          body: body,
          ongoing: ongoing,
          actions: [
            const AndroidNotificationAction(
                'reconnect_now', 'Reconectar Ahora'),
          ]);
    } catch (e) {
      log("❌ Error al actualizar notificación de reconexión: $e",
          error: e, stackTrace: StackTrace.current);
    }
  }

  // --- MÉTODOS PRIVADOS ---

  /// Actualiza la notificación del servicio en segundo plano de manera segura
  Future<void> _safeUpdateNotification(String title, String content) async {
    try {
      final controller = ref.read(backgroundServiceControllerProvider.notifier);
      // Verificar primero si el servicio está en ejecución
      bool isRunning = await controller.backgroundServiceIsRunning();

      if (isRunning) {
        await controller
            .updateServiceNotification(title, content)
            .catchError((e) {
          log("⚠️ Error al actualizar notificación: $e");
        });
      } else {
        log("⚠️ No se actualizó la notificación porque el servicio no está en ejecución");
      }
    } catch (e) {
      log("❌ Error al actualizar notificación: $e",
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Actualiza el estado de conexión interno
  void _updateConnectionStatus(bool isConnected, String message) {
    log("${isConnected ? '✅' : '❌'} Estado de conexión: $isConnected - $message");
    _isConnected = isConnected;
    // Notificar el cambio de estado para que la UI se actualice
    if (mounted) {
      state = state; // Forzar actualización de la UI
    }
  }

  /// Maneja errores de conexión de manera centralizada
  void _handleConnectionError(String message) {
    log("❌ Error de conexión: $message", error: message);
    _updateConnectionStatus(false, message);
    _safeUpdateNotification('Error de conexión', message);
    _scheduleReconnect();
  }

  /// Configura los listeners para el canal WebSocket
  void _listenToChannel(WebSocketChannel channel) {
    channel.stream.listen((message) {
      // Procesar mensaje recibido
      log("📩 Mensaje recibido: $message");

      try {
        final data = jsonDecode(message);
        // Aquí puedes añadir la lógica para procesar mensajes entrantes
        // Por ejemplo, notificar a otros controladores según el tipo de mensaje
      } catch (e) {
        log("❌ Error al procesar mensaje: $e",
            error: e, stackTrace: StackTrace.current);
      }
    }, onError: (err) {
      log("❌ Error en el stream WebSocket: $err",
          error: err, stackTrace: StackTrace.current);
      _handleConnectionError("❌ Error en el WebSocket: $err");
    }, onDone: () {
      log("🔌 Conexión WebSocket cerrada");
      _handleConnectionError("🔌 WebSocket cerrado");
    });
  }

  /// Programa un intento de reconexión
  void _scheduleReconnect() {
    // Si ya alcanzamos el máximo de intentos o ya hay un timer activo, no programar más
    if (_reconnectAttempt >= _maxReconnectAttempts ||
        _reconnectTimer?.isActive == true) {
      if (_reconnectAttempt >= _maxReconnectAttempts) {
        log('🛑 Máximo de reintentos alcanzado ($_maxReconnectAttempts)');
        _safeUpdateNotification('Servicio Detenido',
            'No se pudo reconectar tras $_maxReconnectAttempts intentos. Toque para reintentar.');

        createReconnectionNotification(
          title: 'Error de Conexión',
          body: 'No se pudo conectar al servidor. Toque para reintentar.',
          ongoing: true,
        );

        _safeRestartBackgroundService();
      }
      return;
    }

    // Calcular tiempo de backoff exponencial (aumenta con cada intento)
    final backoffSeconds = _calculateBackoffTime(_reconnectAttempt);

    log('🔄 Programando reintento #${_reconnectAttempt + 1} en $backoffSeconds segundos');

    _reconnectTimer = Timer(Duration(seconds: backoffSeconds), () {
      _reconnectAttempt++;
      log('🔄 Reintento #$_reconnectAttempt de $_maxReconnectAttempts');

      _safeUpdateNotification('Reconectando WebSocket',
          'Intento $_reconnectAttempt de $_maxReconnectAttempts');

      connect();
    });
  }

  /// Calcula el tiempo de espera para backoff exponencial
  int _calculateBackoffTime(int attempt) {
    // Fórmula básica: 2^n segundos con un máximo de 30 segundos
    // 1er intento: 2 seg, 2do: 4 seg, 3ro: 8 seg, 4to: 16 seg, 5to: 30 seg
    return _min(pow(2, attempt + 1).toInt(), 30);
  }

  /// Cancela todos los timers activos
  void _cancelTimers() {
    if (_reconnectTimer?.isActive == true) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    }

    if (_connectionTimeoutTimer?.isActive == true) {
      _connectionTimeoutTimer?.cancel();
      _connectionTimeoutTimer = null;
    }
  }

  /// Reinicia el servicio en segundo plano como último recurso de manera segura
  Future<void> _safeRestartBackgroundService() async {
    log("🔄 Solicitando reinicio del servicio en segundo plano");
    try {
      await ref
          .read(backgroundServiceControllerProvider.notifier)
          .restartService()
          .catchError((e) {
        log("❌ Error al reiniciar servicio: $e");
      });
    } catch (e) {
      log("❌ Error al reiniciar servicio: $e",
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Libera recursos al destruir el notifier
  @override
  void dispose() {
    log("🧹 Limpiando recursos de WSConnectionNotifier");
    _cancelTimers();
    if (state != null) {
      state?.sink.close();
    }
    super.dispose();
  }

  /// Función auxiliar para obtener el mínimo de dos enteros
  int _min(int a, int b) => a < b ? a : b;

  /// Función auxiliar para calcular potencia
  num pow(num x, num exponent) {
    num result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= x;
    }
    return result;
  }
}
