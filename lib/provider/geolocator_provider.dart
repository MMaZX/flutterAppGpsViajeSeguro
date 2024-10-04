import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final getLocationStatusProvider = FutureProvider<(double, double)>((ref) async {
  try {
    await GeoController().getGeolocatorPermission();
    final locationStatus = await Geolocator.getCurrentPosition();
    return (locationStatus.latitude, locationStatus.longitude);
  } catch (e) {
    throw Exception("LOCATION STATUS ERROR : $e");
  }
});

final getLocationStatusStreamProvider =
    StreamProvider.autoDispose<(double, double)>((ref) async* {
  try {
    await GeoController().getGeolocatorPermission();
    await for (final location in Geolocator.getPositionStream()) {
      yield (location.latitude, location.longitude);
    }
  } catch (e) {
    throw Exception("LOCATION STATUS ERROR : $e");
  }
});

class GeoController {
  Future<void> getGeolocatorPermission() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
