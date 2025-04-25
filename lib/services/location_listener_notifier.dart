import 'dart:async';
import 'dart:developer';
import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/provider/permission_provider.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:app_viaje_seguro/services/background_services.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/states/ws_channel_state.dart';
import 'package:app_viaje_seguro/services/ws_connection_provider.dart';
import 'package:app_viaje_seguro/services/ws_listener_notifier.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:shared_preferences/shared_preferences.dart';
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
        log("⚠️ El usuario no es paciente. No se puede iniciar el stream de ubicación.");
        return;
      }
      await getCurrentPositionAsync();
    } catch (e) {
      log("🔴 Error al iniciar el stream de ubicación: ${ExceptionsUtils(e).toString()}");
    }
  }

  // Iniciar el stream de ubicación
  Future<void> passedLocationStream(String rol) async {
    try {
      if (rol.trim().toUpperCase() != 'PACIENTE') {
        log("⚠️ El rol del usuario no es paciente. No se puede iniciar el stream de ubicación.");
        return;
      }
      await getCurrentPositionAsync();
    } catch (e) {
      log("🔴 Error al iniciar el stream de ubicación: ${ExceptionsUtils(e).toString()}");
    }
  }
Future<void> getCurrentPositionAsync() async {
    try {
      log("🟢 Obteniendo la ubicación actual...");
      final position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );

      log("📍 Ubicación actual: ${position.latitude}, ${position.longitude}");

      // Enviar la ubicación al servidor WebSocket
      sendLocationWS(position);
    } catch (e) {
      BackgroundServices().updateLocationNotification(
        "Ubicación NO DISPONIBLE",
        "La ubicación en tu dispositivo no está disponible. Puede que tu dispositivo no sea compatible o que no estén activados los permisos necesarios.",
      );
    }
  }


  Future<void> sendLocationWS(geolocator.Position position) async {
    try {
      final socket = ref.read(wsConnectionProviderNotifier.notifier);

      if (ref.read(wsConnectionProviderNotifier).status !=
          WebSocketStatus.connected) {
        log("❌ WebSocket no está conectado.");
        return;
      }

      final userId = ref.read(userCredentialsProvider).id;

      socket.sendMessage({
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
    // String tipoRol = ref.read(userCredentialsProvider).tipoRol;

    final shred = await SharedPreferences.getInstance();
    String? tipoRol = shred.getString(SharedToken.clienteTipoRol);

    log("👤 Rol detectado: $tipoRol");
    if (tipoRol != 'PACIENTE') {
      log("👤 El rol del usuario no es paciente. CANCELADO");
      return false;
    }

    return true;
  }

  // Future<void> checkPacientesGPS() async {
  //   bool isActive = await isPacienteUser();

  //   log("🔍 Verificando si el usuario es paciente y el stream no está activo...");
  //   if (isActive) {
  //     log("🟢 Condiciones cumplidas, iniciando conexión al stream de ubicación...");
  //     await createStreamConnection();
  //   } else {
  //     log("⚠️ Condiciones no cumplidas. isActive: $isActive");
  //     if (isActive) {
  //       BackgroundServices().updateLocationNotification(
  //         "Servicio Ubicación Incompatible",
  //         "No puedes acceder a la ubicación.",
  //       );
  //     }
  //   }
  // }
}
