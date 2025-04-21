import 'dart:async';
import 'dart:developer';
import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/provider/permission_provider.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:app_viaje_seguro/services/ws_listener_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

final locationStreamProvider =
    StateNotifierProvider<LocationStreamNotifier, bool>((ref) {
  return LocationStreamNotifier(ref);
});

class LocationStreamNotifier extends StateNotifier<bool> {
  final Ref ref;
  LocationStreamNotifier(this.ref) : super(false) {
    //
  }

  // Iniciar el stream de ubicación
  Future<void> startLocationStream() async {
    try {
      bool isPaciente = await isPacienteUser();
      if (!isPaciente) {
        log("🔴 El usuario no es paciente. No se iniciará el stream de ubicación.");
        return;
      }
      log("🟢 Checkeamos permisos...");
      // Verificar permisos de ubicación
      await ref.read(permissionProvider.notifier).checkPermission();

      // Iniciar el stream de ubicación
      log("🟢 Iniciando el stream de ubicación...");
      geolocator.Geolocator.getPositionStream(
        locationSettings: const geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
          distanceFilter: 0, // Notificar cambios cada 10 metros
        ),
      ).listen((position) {
        log("📍 Nueva ubicación: ${position.latitude}, ${position.longitude}");
        // Enviar la ubicación al servidor WebSocket
        sendLocationWS(position);
      });
    } catch (e) {
      log("🔴 Error al iniciar el stream de ubicación: ${ExceptionsUtils(e).toString()}");
    }
  }

  Future<void> sendLocationWS(geolocator.Position position) async {
    try {
         bool wsStatus =
          ref.read(wsConnectionProvider.notifier).isConnectedBackground();
      if (!wsStatus) {
        log("⚠️ WebSocket desconectado, intentando reconectar...");
        ref.read(wsConnectionProvider.notifier).restart();

        // Esperar para ver si se reconecta
        await Future.delayed(const Duration(seconds: 2));
        bool newWsStatus =
          ref.read(wsConnectionProvider.notifier).isConnectedBackground();
        if (!newWsStatus) {
          log("❌ WebSocket sigue desconectado");
          return;
        }

        log("✅ WebSocket reconectado");
      }

      // final userId = ref.read(userCredentialsProvider).id;

      final userId = ref.read(userCredentialsProvider).id;

      ref.read(wsConnectionProvider.notifier).sendMessage({
        "event": "location",
        "lat": position.latitude,
        "lng": position.longitude,
        "id": userId,
      });

      log("✅ Ubicación enviada al servidor");
    } catch (e) {
      log("❌ Error al enviar ubicación: $e");
    }
  }

  Future<bool> isPacienteUser() async {
    final tipoRol = ref.read(userCredentialsProvider).tipoRol.toLowerCase();
    bool wsStatus = ref.read(wsConnectionProvider.notifier).isConnectedBackground();

    if (tipoRol != 'paciente') {
      log("👤 El rol del usuario no es paciente");
      return false;
    }
    if (!wsStatus) {
      log("⚠️ WebSocket no conectado");
      return false;
    }

    return true;
  }
}
