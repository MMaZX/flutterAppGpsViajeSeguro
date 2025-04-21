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
    // Check current permissions status initially without requesting
    requestAllRelevantPermissions();
    checkPermission();
  }
  Future<bool> checkPermission() async {
    log("========================================");
    log("🔍 Checking permissions...");

    final locationFine = await Permission.locationWhenInUse.status;
    log("📍 Location When In Use Permission Status: $locationFine");

    final locationCoarse = await Permission.locationAlways.status;
    log("🌐 Location Always Permission Status: $locationCoarse");

    final notifications = await Permission.notification.status;
    log("🔔 Notifications Permission Status: $notifications");

    state = state.copyWith(
      locationFine: locationFine,
      locationCoarse: locationCoarse,
      notifications: notifications,
    );

    log("✅ Permission check completed. Updated state: $state");
    log("========================================");

    return state.locationGranted &&
        state.locationAlwaysGranted &&
        state.notificationsGranted;
  }

  Future<void> requestAllRelevantPermissions() async {
    try {
      // First check current status before requesting
      await checkPermission();

      if (state.notifications != PermissionStatus.granted) {
        await _requestSinglePermission(Permission.notification);
      }
      // Request permissions that aren't already granted
      if (state.locationFine != PermissionStatus.granted) {
        await _requestSinglePermission(Permission.locationWhenInUse);
      }

      // Only request "always" location if "when in use" is already granted
      if (state.locationFine == PermissionStatus.granted &&
          state.locationCoarse != PermissionStatus.granted) {
        await _requestSinglePermission(Permission.locationAlways);
      }

      // Final check to update state after all requests
      await checkPermission();
    } catch (e) {
      log("ERROR PERMISSION $e");
    }
  }

  Future<void> _requestSinglePermission(Permission permission) async {
    final status = await permission.status;

    // If it's the first time (still in 'denied' status), show the system dialog
    if (status == PermissionStatus.denied) {
      final result = await permission.request();
      log("Requested $permission - Result: $result");
    }
    // If permanently denied, direct to settings
    else if (status == PermissionStatus.permanentlyDenied) {
      log("$permission is permanently denied, opening settings");
      await openAppSettings();
    }
  }

  // Request specific permission and handle the response
  Future<void> requestSpecificPermission(Permission permission) async {
    final status = await permission.status;

    if (status == PermissionStatus.granted) {
      log("$permission is already granted");
      return;
    }

    await _requestSinglePermission(permission);
    await checkPermission(); // Update state after request
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

  bool get locationGranted {
    return locationFine == PermissionStatus.granted;
  }

  bool get locationAlwaysGranted {
    return locationCoarse == PermissionStatus.granted;
  }

  bool get notificationsGranted {
    return notifications == PermissionStatus.granted;
  }

  bool get isFirstInstall {
    // If all permissions are in denied state (not permanently denied),
    // it's likely a first install
    return locationFine == PermissionStatus.denied &&
        locationCoarse == PermissionStatus.denied &&
        notifications == PermissionStatus.denied;
  }

  @override
  String toString() {
    return 'PermissionState(locationFine: $locationFine, locationCoarse: $locationCoarse, notifications: $notifications)';
  }

  PermissionState copyWith({
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
