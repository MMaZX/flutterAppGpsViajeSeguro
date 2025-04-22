import 'dart:async';
import 'dart:developer';
import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/provider/permission_provider.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:app_viaje_seguro/services/background_services.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
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

  bool isPacienteActive = false;

  // Iniciar el stream de ubicación
  Future<void> startLocationStream() async {
    try {
      bool isPaciente = await isPacienteUser();
      if (!isPaciente) {
        return;
      }
      await createStreamConnection();
    } catch (e) {
      isPacienteActive = false;
      log("🔴 Error al iniciar el stream de ubicación: ${ExceptionsUtils(e).toString()}");
    }
  }

  Future<void> createStreamConnection() async {
    // log("🟢 Checkeamos permisos...");
    // Verificar permisos de ubicación
    // await ref.read(permissionProvider.notifier).checkPermission();

    // Iniciar el stream de ubicación
    log("🟢 Iniciando el stream de ubicación...");
    try {
      geolocator.Geolocator.getPositionStream(
        locationSettings: const geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
          distanceFilter: 0, // Notificar cambios cada 10 metros
          timeLimit: Duration(seconds: 5),
        ),
      ).listen((position) {
        isPacienteActive = true;

        log("📍 Nueva ubicación: ${position.latitude}, ${position.longitude}");
        // Enviar la ubicación al servidor WebSocket
        sendLocationWS(position);
      }).onError((error) {
        updateNotification(
          "Ubicación NO DISPONIBLE",
          "La ubicación en tu dispositivo no está disponible. Puede que tu dispositivo no sea compatible o que no estén activados los permisos necesarios.",
        );
      });
    } catch (e) {
      updateNotification(
        "Ubicación NO DISPONIBLE",
        "La ubicación en tu dispositivo no está disponible. Puede que tu dispositivo no sea compatible o que no estén activados los permisos necesarios.",
      );
    }
  }

  Future<void> sendLocationWS(geolocator.Position position) async {
    try {
      bool wsStatus = ref.read(wsConnectionProvider.notifier).isConnected;
      if (!wsStatus) {
        log("⚠️ WebSocket desconectado, intentando reconectar...");
        ref.read(wsConnectionProvider.notifier).restart();

        // Esperar para ver si se reconecta
        await Future.delayed(const Duration(seconds: 1));
        bool newWsStatus = ref.read(wsConnectionProvider.notifier).isConnected;
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
      updateNotification(
        "Ubicación actualizada",
        "GEO: Lat: ${position.latitude}, Lng: ${position.longitude}",
      );
      log("✅ Ubicación enviada al servidor");
    } catch (e) {
      isPacienteActive = false;
      log("❌ Error al enviar ubicación: $e");
    }
  }

  Future<bool> isPacienteUser() async {
    final tipoRol = ref.read(userCredentialsProvider).tipoRol.toLowerCase();
    bool wsStatus = ref.read(wsConnectionProvider.notifier).isConnected;

    if (tipoRol != 'paciente') {
      log("👤 El rol del usuario no es paciente. CANCELADO");
      return false;
    }
    if (!wsStatus) {
      log("⚠️ WebSocket no conectado. CANCELADO");
      return false;
    }

    return true;
  }

  Future<void> checkPacientesGPS() async {
    bool isActive = await isPacienteUser();

    log("🔍 Verificando si el usuario es paciente y el stream no está activo...");
    if (isActive) {
      log("🟢 Condiciones cumplidas, iniciando conexión al stream de ubicación...");
      await createStreamConnection();
    } else {
      log("⚠️ Condiciones no cumplidas. isActive: $isActive, isPacienteActive: $isPacienteActive");
      if (isActive) {
        updateNotification(
          "Servicio Ubicación Incompatible",
          "No puedes acceder a la ubicación.",
        );
      }
    }
  }

  /// Actualiza la notificación del servicio en segundo plano
  void updateNotification(String title, String content) {
    _showNotification(title, content);
  }

  void _showNotification(String title, String content) async {
    try {
      final controller = ref.read(backgroundServiceControllerProvider.notifier);
      await controller.updateLocationNotification(title, content);
    } catch (e) {
      log("❌ NO SE PUDO ACTIVAR LA NOTIFICACIÓN DE UBICACIÓN: $e",
          error: e, stackTrace: StackTrace.current);
    }
  }
}
