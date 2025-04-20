// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:permission_handler/permission_handler.dart';

// final permissionProvider =
//     StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
//   return PermissionNotifier();
// });

// class PermissionNotifier extends StateNotifier<PermissionState> {
//   PermissionNotifier() : super(PermissionState());

//   Future<void> checkPermission() async {
//     final permissionLocation = await Permission.location.status;

//     state = state.copyWith(
//       location: permissionLocation,
//     );
//   }

//   Future<void> requestAccessCamera() async {
//     try {
//       final status = await Permission.location.request();
//       state = state.copyWith(location: status);
//       _requestStatusSettings(status);
//     } catch (e) {
//       log("ERROR PERMISSION $e");
//     }
//   }
//   // PERMISSION LOCATION
//   _requestStatusSettings(PermissionStatus status) {
//     if (status == PermissionStatus.denied ||
//         status == PermissionStatus.permanentlyDenied) {
//       openAppSettings();
//     }
//   }


// }

// class PermissionState {
//   final PermissionStatus location;

//   PermissionState({this.location = PermissionStatus.denied});

//   get locationGranted {
//     return location == PermissionStatus.granted;
//   }

//   copyWith({PermissionStatus? location}) {
//     return PermissionState(
//       location: location ?? this.location,
//     );
//   }
// }

// final observerAppProvider = StateProvider<AppLifecycleState>((ref) {
//   return AppLifecycleState.resumed;
// });

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
  return PermissionNotifier();
});

class PermissionNotifier extends StateNotifier<PermissionState> {
  PermissionNotifier() : super(PermissionState()) {
    // Solicitar permisos al inicializar el notifier (primera vez)
    requestAllRelevantPermissions();
  }

  Future<void> checkPermission() async {
    final locationFine = await Permission.location.status;
    final locationCoarse = await Permission
        .locationAlways.status; // Para ACCESS_BACKGROUND_LOCATION
    final notifications = await Permission.notification.status;

    state = state.copyWith(
      locationFine: locationFine,
      locationCoarse: locationCoarse,
      notifications: notifications,
    );
  }

  Future<void> requestAllRelevantPermissions() async {
    try {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission
            .locationWhenInUse, // Para ACCESS_FINE_LOCATION y ACCESS_COARSE_LOCATION (mientras se usa)
        Permission.locationAlways, // Para ACCESS_BACKGROUND_LOCATION
        Permission.notification, // Para POST_NOTIFICATIONS
      ].request();

      state = state.copyWith(
        locationFine:
            statuses[Permission.locationWhenInUse] ?? state.locationFine,
        locationCoarse:
            statuses[Permission.locationAlways] ?? state.locationCoarse,
        notifications: statuses[Permission.notification] ?? state.notifications,
      );

      // Verificar y abrir configuración si algún permiso fue denegado permanentemente
      statuses.forEach((permission, status) {
        _requestStatusSettings(status);
      });
    } catch (e) {
      log("ERROR PERMISSION $e");
    }
  }

  // PERMISSION LOCATION
  _requestStatusSettings(PermissionStatus status) {
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }
  }
}

class PermissionState {
  final PermissionStatus locationFine;
  final PermissionStatus locationCoarse;
  final PermissionStatus notifications;

  PermissionState({
    this.locationFine = PermissionStatus.denied,
    this.locationCoarse = PermissionStatus.denied,
    this.notifications = PermissionStatus.denied,
  });

  get locationGranted {
    return locationFine == PermissionStatus.granted ||
        locationCoarse == PermissionStatus.granted ||
        locationFine == PermissionStatus.granted ||
        locationCoarse == PermissionStatus.granted;
  }

  get locationAlwaysGranted {
    return locationCoarse == PermissionStatus.granted ||
        locationCoarse == PermissionStatus.granted;
  }

  get notificationsGranted {
    return notifications == PermissionStatus.granted;
  }

  copyWith({
    PermissionStatus? locationFine,
    PermissionStatus? locationCoarse,
    PermissionStatus? notifications,
  }) {
    return PermissionState(
      locationFine: locationFine ?? this.locationFine,
      locationCoarse: locationCoarse ?? this.locationCoarse,
      notifications: notifications ?? this.notifications,
    );
  }
}

final observerAppProvider = StateProvider<AppLifecycleState>((ref) {
  return AppLifecycleState.resumed;
});
