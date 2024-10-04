import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

final permissionProvider =
    StateNotifierProvider<PermissionNotifier, PermissionState>((ref) {
  return PermissionNotifier();
});

class PermissionNotifier extends StateNotifier<PermissionState> {
  PermissionNotifier() : super(PermissionState());

  Future<void> checkPermission() async {
    final permissionLocation = await Permission.location.status;

    state = state.copyWith(
      location: permissionLocation,
    );
  }

  Future<void> requestAccessCamera() async {
    try {
      final status = await Permission.location.request();
      state = state.copyWith(location: status);
      _requestStatusSettings(status);
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
  final PermissionStatus location;

  PermissionState({this.location = PermissionStatus.denied});

  get locationGranted {
    return location == PermissionStatus.granted;
  }

  copyWith({PermissionStatus? location}) {
    return PermissionState(
      location: location ?? this.location,
    );
  }
}

final observerAppProvider = StateProvider<AppLifecycleState>((ref) {
  return AppLifecycleState.resumed;
});
