import 'dart:developer';

import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/provider/geolocator_provider.dart';
import 'package:app_viaje_seguro/services/ws_listener_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapboxMap? mapboxMap;

  @override
  void initState() {
    super.initState();
    // Solicitar permisos y obtener la ubicación inicial al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).checkAndRequestPermission();
    });
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;

    // Configurar ubicación
    mapboxMap.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        puckBearingEnabled: true,
        showAccuracyRing: true,
        pulsingEnabled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa con ubicación')),
      body: Column(
        children: [
          Expanded(
            child: MapWidget(
              key: const ValueKey("mapWidget"),
              onMapCreated: _onMapCreated,
              cameraOptions: CameraOptions(
                center: locationState.position ??
                    Point(coordinates: Position(-98.0, 39.5)),
                zoom: 14.0,
              ),
              // styleUri: MapboxStyles.LIGHT,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: ShadCard(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              title: SizedBox(
                width: double.maxFinite,
                child: Text(
                    'Estado de permisos: ${locationState.hasPermission ? "Concedido" : "No concedido"}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.p.copyWith(
                      height: 0,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    )),
              ),
              description: locationState.position != null
                  ? Text(
                      'Ubicación actual: Lat: ${locationState.position!.coordinates.lat}, '
                      'Lng: ${locationState.position!.coordinates.lng}',
                    )
                  : const Text('Ubicación no disponible'),
              trailing: ShadButton.outline(
                onPressed: () {
                  ref
                      .read(locationProvider.notifier)
                      .requestLocationPermission();
                },
                icon: const Icon(Icons.location_on),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   icon: const Icon(Icons.my_location),
      //   label: const Text('Mi ubicación'),
      //   onPressed: () {
      //     ref.read(locationProvider.notifier).getCurrentLocation();
      //   },
      // ),
    );
  }
}

class UserLocation {
  final Point? position;
  final bool hasPermission;
  final bool isLoading;

  UserLocation({
    this.position,
    this.hasPermission = false,
    this.isLoading = false,
  });

  UserLocation copyWith({
    Point? position,
    bool? hasPermission,
    bool? isLoading,
  }) {
    return UserLocation(
      position: position ?? this.position,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, UserLocation>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<UserLocation> {
  LocationNotifier() : super(UserLocation());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true);
    try {
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        state = state.copyWith(hasPermission: false, isLoading: false);
        return;
      }
      final position = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );
      state = state.copyWith(
        position:
            Point(coordinates: Position(position.longitude, position.latitude)),
        hasPermission: true,
        isLoading: false,
      );
    } catch (e) {
      log("Error al obtener la ubicación actual: $e");
      state = state.copyWith(isLoading: false);
      // Puedes manejar el error de manera más específica aquí
    }
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    state = state.copyWith(hasPermission: status.isGranted);
    return status.isGranted;
  }

  Future<bool> _checkLocationPermission() async {
    final status = await Permission.location.status;
    state = state.copyWith(hasPermission: status.isGranted);
    return status.isGranted;
  }

  Future<void> checkAndRequestPermission() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      await requestLocationPermission();
    } else {
      getCurrentLocation(); // Obtener la ubicación si ya tiene permisos
    }
  }
}
