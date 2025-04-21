import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EnumNotificationChannel {
  service(
    canalId: 'channel_services_notification',
    titulo: 'Notificaciones Services',
    descripcion: 'Este canal es para notificaciones importantes del servicio.',
    importance: Importance.high,
  ),
  reconnection(
    canalId: 'reconnection_channel_id',
    titulo: 'Reconexión WebSocket',
    descripcion: 'Notificaciones sobre el estado de la conexión WebSocket.',
    importance: Importance.low,
  ),
  location(
    canalId: 'location_channel_id',
    titulo: 'Ubicación en Tiempo Real',
    descripcion: 'Este canal muestra cuando la ubicación se está compartiendo.',
    importance: Importance.low,
  ),
  newRequest(
    canalId: 'new_request_channel_id',
    titulo: 'Nuevas Solicitudes',
    descripcion: 'Notificaciones sobre nuevas solicitudes entrantes.',
    importance: Importance.high,
  );

  final String canalId;
  final String titulo;
  final String descripcion;
  final Importance importance;

  const EnumNotificationChannel({
    required this.canalId,
    required this.titulo,
    required this.descripcion,
    required this.importance,
  });

  AndroidNotificationChannel toAndroidNotificationChannel() {
    return AndroidNotificationChannel(
      canalId,
      titulo,
      description: descripcion,
      importance: importance,
    );
  }

  AndroidNotificationDetails toAndroidNotificationDetails({
    String? channelDescription,
    bool ongoing = false,
    Priority priority = Priority.defaultPriority,
    bool playSound = true,
    List<AndroidNotificationAction>?
        actions, // ✅ Nuevo parámetro para las acciones
    bool enableVibration = true,
  }) {
    return AndroidNotificationDetails(
      canalId,
      titulo,
      channelDescription: channelDescription ?? descripcion,
      importance: importance,
      priority: priority,
      ongoing: ongoing,
      playSound: playSound,
      enableVibration: enableVibration,
      actions: actions, // ✅ Usamos el parámetro actions
    );
  }
}

// Primero, creamos un proveedor para la inicialización de notificaciones
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Clase para gestionar las notificaciones
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
      await androidImplementation.createNotificationChannel(
          EnumNotificationChannel.service.toAndroidNotificationChannel());
      await androidImplementation.createNotificationChannel(
          EnumNotificationChannel.reconnection.toAndroidNotificationChannel());
      await androidImplementation.createNotificationChannel(
          EnumNotificationChannel.location.toAndroidNotificationChannel());
      await androidImplementation.createNotificationChannel(
          EnumNotificationChannel.newRequest.toAndroidNotificationChannel());
    }
  }

  Future<void> showNotification({
    required int id,
    required EnumNotificationChannel channel,
    required String title,
    required String body,
    bool ongoing = false,
    Priority priority = Priority.defaultPriority,
    bool playSound = true,
    bool vibrate = true,
    List<AndroidNotificationAction>? actions,
  }) async {
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: channel.toAndroidNotificationDetails(
          ongoing: ongoing,
          priority: priority,
          playSound: playSound,
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
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
