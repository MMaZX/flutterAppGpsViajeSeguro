import 'dart:convert';
import 'dart:math';
import 'package:app_viaje_seguro/model/retrievev2_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class CloudController {
  final WidgetRef ref;
  Dio dio = Dio();

  CloudController({required this.ref});
  Future<MapBoxRetrieveV2> getAutoCompleteMapsData({
    required String input,
  }) async {
    Uri uri = Uri.https('api.mapbox.com', 'search/geocode/v6/forward', {
      'q': input,
      "proximity": "ip",
      "country": "pe",
      "language": "es",
      'access_token': _apikeyValue,
      'session_token': '1234567890',
    });
    if (input.isEmpty) {
      ref.invalidate(suggestionsMapSearchBoxProvider);
      return MapBoxRetrieveV2.fromDefault();
    }
    try {
      final response = await dio.get(uri.toString());
      final json = jsonEncode(response.data);
      final data = jsonDecode(json);
      final modelData = MapBoxRetrieveV2.fromJson(data);
      ref
          .read(suggestionsMapSearchBoxProvider.notifier)
          .update((state) => modelData);
      return modelData;
    } on DioException catch (e) {
      debugPrint(e.response.toString());
      return MapBoxRetrieveV2.fromDefault();
    }
  }
}

String _apikeyValue =
    "pk.eyJ1IjoiamVhc29uY3VlcyIsImEiOiJjbHNhaTMyNXIwM3hqMmxxbWMxcTVydWx4In0.-ZufkZ_hQohVi6iLX8bsrA";

final suggestionsMapSearchBoxProvider = StateProvider<MapBoxRetrieveV2>((ref) {
  return MapBoxRetrieveV2.fromDefault();
});

final retrieveMapSearchBoxProvider = StateProvider<Feature>((ref) {
  return Feature.fromJson(null);
});

class MapBoxSearch {
  final String name;
  final String mapboxId;
  final String featureType;
  final String address;
  final String fullAddress;
  final String placeFormatted;
  final String language;
  final String maki;
  final List<dynamic> poiCategory;
  MapBoxSearch(
      {required this.name,
      required this.mapboxId,
      required this.featureType,
      required this.address,
      required this.fullAddress,
      required this.placeFormatted,
      required this.language,
      required this.maki,
      required this.poiCategory});

  factory MapBoxSearch.fromJson(Map<String, dynamic> json) {
    // print(json);
    return MapBoxSearch(
      name: json['name'] ?? 'null',
      mapboxId: json['mapbox_id'] ?? 'null',
      featureType: json['feature_type'] ?? 'null',
      address: json['address'] ?? 'null',
      fullAddress: json['full_address'] ?? 'null',
      placeFormatted: json['place_formatted'] ?? 'null',
      language: json['language'] ?? 'null',
      maki: json['maki'] ?? 'null',
      poiCategory: json['poi_category'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mapboxId': mapboxId,
      'featureType': featureType,
      'address': address,
      'fullAddress': fullAddress,
      'placeFormatted': placeFormatted,
      'language': language,
      'maki': maki,
      'poiCategory': poiCategory,
    };
  }
}

double getDistance(LatLng point1, LatLng point2) {
  const int radius = 6371; // Radio de la Tierra en kilómetros
  double lat1 = point1.latitude;
  double lat2 = point2.latitude;
  double lon1 = point1.longitude;
  double lon2 = point2.longitude;

  // Convertir grados a radianes
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);

  // Aplicar fórmula del Haversine
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * asin(sqrt(a));

  // Retornar la distancia en kilómetros
  return (radius * c);
}

double _toRadians(double degree) {
  return degree * pi / 180;
}
