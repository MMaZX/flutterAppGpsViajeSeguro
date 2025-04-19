import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:riverpod/riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:developer';

final wsConnectionProvider =
    StateNotifierProvider<WSConnectionNotifier, WebSocketChannel?>((ref) {
  return WSConnectionNotifier(ref);
});

final wsConnectionStatusProvider =
    StateProvider<String>((ref) => 'Desconectado');

class WSConnectionNotifier extends StateNotifier<WebSocketChannel?> {
  final Ref ref;
  WSConnectionNotifier(this.ref) : super(null);

  void connect(String url) {
    final channel = WebSocketChannel.connect(Uri.parse(url));
    state = channel;
    ref.read(wsConnectionStatusProvider.notifier).state = 'Conectado';
    log('✅ Conectado a $url');
  }

  void disconnect() {
    state?.sink.close();
    state = null;
    ref.read(wsConnectionStatusProvider.notifier).state = 'Desconectado';
    log('🔌 Desconectado del WebSocket');
  }

  void sendMessage(Map<String, dynamic> message) {
    state?.sink.add(jsonEncode(message));
  }
}

final wsMessageListenerProvider =
    StateNotifierProvider<WSMessageListenerNotifier, List<String>>((ref) {
  return WSMessageListenerNotifier(ref);
});

class WSMessageListenerNotifier extends StateNotifier<List<String>> {
  final Ref ref;

  WSMessageListenerNotifier(this.ref) : super([]) {
    _initListener();
  }

  // void _initListener() {
  //   final channel = ref.read(wsConnectionProvider);
  //   channel?.stream.listen((message) {
  //     final data = jsonDecode(message);
  //     _handleMessage(data);
  //   });
  // }

  void _initListener() {
    final channel = ref.read(wsConnectionProvider);
    if (channel == null) {
      log("❌ WebSocket no está conectado");
      return;
    }

    log("✅ WebSocket conectado");

    channel.stream.listen((message) {
      log("📩 Mensaje recibido del servidor: $message");
      final data = jsonDecode(message);
      _handleMessage(data);
    }, onError: (err) {
      log("❌ Error en el WebSocket: $err");
    }, onDone: () {
      log("🔌 WebSocket cerrado");
    });
  }

  void _handleMessage(dynamic data) {
    // ejemplo simple para notificación local
    if (data['type'] == 'new-request') {
      _showNotification("Solicitud Nueva", "Tienes una nueva solicitud");
    }
    state = [...state, jsonEncode(data)];
  }

  Future<void> _showNotification(String title, String body) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails);
  }
}

Future<void> initializeService() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Creamos el canal aquí
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'channel_services_notification', // channelId único
    'Notificaciones Services',
    description: 'Este canal es para notificaciones importantes.',
    importance: Importance.high,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'channel_services_notification',
      initialNotificationTitle: 'Servicio Activo WS',
      initialNotificationContent: 'Escuchando solicitudes...',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: (_) => true,
    ),
  );

  await service.startService();
}

void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  final channel = WebSocketChannel.connect(Uri.parse('ws://localhost:3000'));

  channel.stream.listen((message) async {
    final data = jsonDecode(message);
    if (data['type'] == 'new-request') {
      final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const androidDetails = AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        "Solicitud Nueva",
        "Tienes una nueva solicitud entrante",
        notificationDetails,
      );
    }
  });
}

// En tu main.dart o donde inicies la app
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeService();
//   runApp(ProviderScope(child: MyApp()));
// }
