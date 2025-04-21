import 'dart:developer';
import 'package:app_viaje_seguro/main.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../firebase_options.dart';
import '../services/background_services.dart';

class AppInitializer {
  final ProviderContainer container = ProviderContainer();

  Future<void> initialize() async {
    log("🛠️ Inicializando App...");
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Mapbox
    MapboxOptions.setAccessToken(ACCESS_TOKEN);
  }

  Future<void> initNotificationServices() async {
    container.read(notificationServiceProvider).initialize();

    // Inicializar background service controller
    final backgroundController =
        container.read(backgroundServiceControllerProvider.notifier);
    await backgroundController.initialize();
  }

   Future<void> startBackgroundService() async {
    final backgroundController =
        container.read(backgroundServiceControllerProvider.notifier);
    await backgroundController.startService();
  }

  ProviderContainer getProviderContainer() {
    return container;
  }
}
