import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/pages/maps/map_screen.dart';
import 'package:app_viaje_seguro/provider/session_provider.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/notifications_controller_services.dart';
import 'package:app_viaje_seguro/services/web_socket_service_background.dart';
import 'package:app_viaje_seguro/services/ws_channel_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:developer';

import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

// IDs constantes para las notificaciones
const int locationNotificationId = 3;
const int newRequestNotificationId = 2;

final locationChannelListenerProvider =
    StateNotifierProvider<WSMessageListenerNotifier, List<String>>((ref) {
  return WSMessageListenerNotifier(ref);
});

class WSMessageListenerNotifier extends StateNotifier<List<String>> {
  final Ref ref;
  bool _isLoggedIn = false;
  Timer? _locationUpdateTimer;

  WSMessageListenerNotifier(this.ref) : super([]) {
    _checkLoginStatus();
    startLocationUpdatesIfPaciente();
  }

  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await AuthPrefs().isLoggedIn();
  }

  Future<void> startLocationUpdatesIfPaciente() async {
    await _checkLoginStatus();
    final tipo = await AuthPrefs().getTipoRol();
    final wsStatus = ref.read(wsChannelStateProvider).isEnabled;

    if (_isLoggedIn && tipo.toLowerCase() == 'paciente' && wsStatus) {
      startListeningLocationUpdates();
      _showLocationActiveNotification();
    } else {
      if (!_isLoggedIn) {
        log("🔒 Usuario no logueado, no se iniciará el envío de ubicación.");
      } else if (tipo.toLowerCase() != 'paciente') {
        log("👤 El rol del usuario no es paciente, no se iniciará el envío de ubicación.");
      } else if (!wsStatus) {
        log("⚠️ WebSocket no conectado, no se puede iniciar el envío de ubicación.");
      }

      // Cancelar el timer si existe
      _locationUpdateTimer?.cancel();
      _locationUpdateTimer = null;
    }
  }

  void startListeningLocationUpdates() async {
    final wsStatus = ref.read(wsChannelStateProvider).isEnabled;

    // Primero cancelamos cualquier timer anterior
    _locationUpdateTimer?.cancel();

    final permission = await geolocator.Geolocator.checkPermission();
    if (permission == geolocator.LocationPermission.denied ||
        permission == geolocator.LocationPermission.deniedForever) {
      final result = await geolocator.Geolocator.requestPermission();
      if (result != geolocator.LocationPermission.always &&
          result != geolocator.LocationPermission.whileInUse) {
        log("❌ Permiso de ubicación denegado.");
        return;
      }
    }

    const geolocator.LocationSettings locationSettings =
        geolocator.LocationSettings(
      accuracy: geolocator.LocationAccuracy.high,
      distanceFilter: 0,
      timeLimit: Duration(seconds: 5),
    );

    geolocator.Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((geolocator.Position position) async {
      final point = mapbox.Point(
        coordinates: mapbox.Position(position.longitude, position.latitude),
      );

      log("📍 Stream - Nueva posición: ${point.coordinates.lat}, ${point.coordinates.lng}");

      final tipo = await AuthPrefs().getTipoRol();
      final isLoggedIn = await AuthPrefs().isLoggedIn();
      if (isLoggedIn && tipo.toLowerCase() == 'paciente' && wsStatus) {
        ref.read(wsConnectionProvider.notifier).sendMessage({
          "event": "location",
          "lat": point.coordinates.lat,
          "lng": point.coordinates.lng,
          "id": await AuthPrefs().getId()
        });

        // Actualizar la notificación con la posición actual periódicamente
        // pero no en cada cambio para evitar demasiadas actualizaciones
        if (_locationUpdateTimer == null || !_locationUpdateTimer!.isActive) {
          _locationUpdateTimer =
              Timer.periodic(const Duration(minutes: 2), (_) {
            _updateLocationNotification(
              lat: point.coordinates.lat.toDouble(),
              lng: point.coordinates.lng.toDouble(),
            );
          });
        }
      }
    });
  }

  Future<void> updateLocation() async {
    await _checkLoginStatus();
    final tipo = await AuthPrefs().getTipoRol();
    final wsStatus = ref.read(wsChannelStateProvider).isEnabled;

    if (_isLoggedIn && tipo.toLowerCase() == 'paciente' && wsStatus) {
      try {
        ref.read(locationProvider.notifier).requestLocationPermission();
        final position = await geolocator.Geolocator.getCurrentPosition();
        final point = mapbox.Point(
            coordinates:
                mapbox.Position(position.longitude, position.latitude));

        log("📍 Ubicación actualizada en tiempo real (única vez): ${point.coordinates.lat}, ${point.coordinates.lng}");

        ref.read(wsConnectionProvider.notifier).sendMessage({
          "event": "location",
          "lat": point.coordinates.lat,
          "lng": point.coordinates.lng,
          "id": await AuthPrefs().getId()
        });

        // Actualizar la notificación con la ubicación actual
        _updateLocationNotification(
          lat: point.coordinates.lat.toDouble(),
          lng: point.coordinates.lng.toDouble(),
        );
      } catch (e) {
        log("❌ Error al obtener la ubicación: $e");
      }
    } else {
      if (!_isLoggedIn) {
        log("🔒 Usuario no logueado, no se puede actualizar la ubicación.");
      } else if (tipo.toLowerCase() != 'paciente') {
        log("👤 El rol del usuario no es paciente, no se puede actualizar la ubicación.");
      } else if (!wsStatus) {
        log("⚠️ WebSocket no conectado, no se puede actualizar la ubicación.");
      }
    }
  }

  void handleMessage(dynamic data) {
    if (data is Map && data['type'] == 'new-request') {
      _showNewRequestNotification();
    }
    state = [...state, jsonEncode(data)];
  }

  // Método para mostrar notificación de ubicación activa
  Future<void> _showLocationActiveNotification() async {
    final backgroundController =
        ref.read(backgroundServiceControllerProvider.notifier);
    await backgroundController.showCustomNotification(
      id: locationNotificationId,
      channelId: 'location_channel_id',
      title: 'Ubicación Activada',
      body: 'Compartiendo tu ubicación con tus familiares.',
      ongoing: true,
    );
  }

  // Método para actualizar la notificación de ubicación con las coordenadas actuales
  Future<void> _updateLocationNotification(
      {required double lat, required double lng}) async {
    final backgroundController =
        ref.read(backgroundServiceControllerProvider.notifier);

    // Formateamos las coordenadas para mostrar solo 5 decimales
    String latFormatted = lat.toStringAsFixed(5);
    String lngFormatted = lng.toStringAsFixed(5);

    await backgroundController.showCustomNotification(
      id: locationNotificationId,
      channelId: 'location_channel_id',
      title: 'Ubicación Compartida',
      body: 'Compartiendo ubicación: $latFormatted, $lngFormatted',
      ongoing: true,
    );
  }

  // Método para mostrar notificación de nueva solicitud
  Future<void> _showNewRequestNotification() async {
    final backgroundController =
        ref.read(backgroundServiceControllerProvider.notifier);
    await backgroundController.showCustomNotification(
      id: newRequestNotificationId,
      channelId: 'new_request_channel_id',
      title: 'Solicitud Nueva',
      body: 'Tienes una nueva solicitud',
      ongoing: false,
    );
  }

  // Método para detener actualizaciones de ubicación y cancelar la notificación
  void stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;

    // Cancelar la notificación de ubicación
    final backgroundController =
        ref.read(backgroundServiceControllerProvider.notifier);
    backgroundController.cancelNotification(locationNotificationId);
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
}

void startLocationStreamForPaciente(ProviderContainer container) {
  // Verificamos el rol del usuario y si está logueado
  AuthPrefs().isLoggedIn().then((isLoggedIn) {
    if (!isLoggedIn) {
      log("🔒 Usuario no logueado, no se iniciará el envío periódico de ubicación.");
      return;
    }

    AuthPrefs().getTipoRol().then((tipo) {
      if (tipo.toLowerCase() != 'paciente') {
        log("👤 El rol del usuario no es paciente, no se iniciará el envío periódico de ubicación.");
        return;
      }

      log("✅ Iniciando stream periódico de ubicación para paciente");

      // Configuramos el stream para que se ejecute cada 5 segundos
      Timer.periodic(const Duration(seconds: 5), (timer) async {
        final wsStatus = container.read(wsChannelStateProvider).isEnabled;
        if (!wsStatus) {
          log("⚠️ WebSocket no conectado, no se enviará la ubicación periódica.");
          return;
        }

        try {
          final position = await geolocator.Geolocator.getCurrentPosition(
            desiredAccuracy: geolocator.LocationAccuracy.high,
          );

          final point = mapbox.Point(
            coordinates: mapbox.Position(position.longitude, position.latitude),
          );

          log("📍 Stream - Enviando ubicación periódica: ${point.coordinates.lat}, ${point.coordinates.lng}");

          // Enviamos la ubicación al WebSocket
          container.read(wsConnectionProvider.notifier).sendMessage({
            "event": "location",
            "lat": point.coordinates.lat,
            "lng": point.coordinates.lng,
            "id": await AuthPrefs().getId()
          });
        } catch (e) {
          log("❌ Error al obtener o enviar la ubicación periódica: $e");
        }
      });
    });
  });
}
