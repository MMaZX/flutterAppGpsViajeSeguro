import 'package:app_viaje_seguro/provider/geolocator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).requestLocationPermission();
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

  Future<void> _obtenerUbicacionYActualizarMapa() async {
    try {
      final pos = await geolocator.Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
      );

      final point = Point(coordinates: Position(pos.longitude, pos.latitude));
      print("🧭 Ubicación actual: Lat: ${pos.latitude}, Lng: ${pos.longitude}");

      // Actualizar en Riverpod
      ref.read(locationProvider.notifier).updateUserPosition(point);

      // Centrar el mapa
      mapboxMap?.flyTo(
        CameraOptions(center: point, zoom: 14.0),
        MapAnimationOptions(duration: 1500),
      );
    } catch (e) {
      print("❌ Error obteniendo ubicación: $e");
    }
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
                onPressed: () => ref
                    .read(locationProvider.notifier)
                    .requestLocationPermission(),
                icon: const Icon(Icons.location_on),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   icon: const Icon(Icons.my_location),
      //   label: const Text('Mi ubicación'),
      //   onPressed: _obtenerUbicacionYActualizarMapa,
      // ),
    );
  }
}

// Modelo para almacenar la ubicación
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

// StateNotifier para manejar la ubicación
class LocationNotifier extends StateNotifier<UserLocation> {
  LocationNotifier() : super(UserLocation(isLoading: false));

  // Solicitar permisos de ubicación
  Future<void> requestLocationPermission() async {
    state = state.copyWith(isLoading: true);

    var status = await Permission.locationWhenInUse.request();
    state = state.copyWith(
      hasPermission: status.isGranted,
      isLoading: false,
    );
  }

  // Actualizar la posición del usuario (esto se llamaría desde el mapa)
  void updateUserPosition(Point position) {
    state = state.copyWith(position: position);
  }
}

// Provider para el StateNotifier
final locationProvider =
    StateNotifierProvider<LocationNotifier, UserLocation>((ref) {
  return LocationNotifier();
});
