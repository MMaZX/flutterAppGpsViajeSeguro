import 'dart:async';
import 'dart:developer';

import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/services/web_socket_service_background.dart';
import 'package:app_viaje_seguro/services/ws_channel_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

final locationStreamProvider =
    StateNotifierProvider<LocationStreamNotifier, bool>((ref) {
  return LocationStreamNotifier(ref);
});

class LocationStreamNotifier extends StateNotifier<bool> {
  LocationStreamNotifier(this._ref) : super(false);

  final Ref _ref;
  StreamSubscription<geolocator.Position>? _positionSubscription;

  Future<void> start() async {
    final isLoggedIn = await AuthPrefs().isLoggedIn();
    if (!isLoggedIn) {
      log("🔒 Usuario no logueado, cancelando inicio de ubicación");
      return;
    }

    final tipo = await AuthPrefs().getTipoRol();
    if (tipo.toLowerCase() != 'paciente') {
      log("👤 No es paciente, cancelando inicio de ubicación");
      return;
    }

    _positionSubscription?.cancel(); // cancelar si ya estaba

    const locationSettings = geolocator.LocationSettings(
      accuracy: geolocator.LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription = geolocator.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) async {
      final statusWS = _ref.read(wsChannelStateProvider).isEnabled;

      if (!statusWS) {
        log("⚠️ WebSocket no conectado, intentando forzar la conexión...");
        _ref.read(wsConnectionProvider.notifier).forceReconnect();

        // Esperar un momento para verificar si se reconecta
        await Future.delayed(const Duration(seconds: 2));
        final newStatusWS = _ref.read(wsChannelStateProvider).isEnabled;

        if (!newStatusWS) {
          log("❌ WebSocket sigue desconectado, no se enviará ubicación");
          return;
        }

        log("✅ WebSocket reconectado exitosamente, enviando ubicación...");
      }

      final point = mapbox.Point(
        coordinates: mapbox.Position(position.longitude, position.latitude),
      );

      log("📍 Stream - Nueva posición: ${point.coordinates.lat}, ${point.coordinates.lng}");

      _ref.read(wsConnectionProvider.notifier).sendMessage({
        "event": "location",
        "lat": point.coordinates.lat,
        "lng": point.coordinates.lng,
        "id": await AuthPrefs().getId(),
      });
    });

    state = true;
    log("🟢 Servicio de ubicación iniciado");
  }

  void stop() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    state = false;
    log("🔴 Servicio de ubicación detenido");
  }
}
