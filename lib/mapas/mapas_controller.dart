// map_controller.dart
import 'dart:async'; // Necesario para StreamSubscription
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data'; // Necesario para Uint8List
import 'dart:ui';

import 'package:app_viaje_seguro/main.dart'; // Asegúrate que ACCESS_TOKEN esté aquí o importado correctamente
import 'package:app_viaje_seguro/mapas/mapas_state.dart'; // Asegúrate que la ruta sea correcta
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Necesario para Color
import 'package:flutter/services.dart'; // Necesario para rootBundle
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart'
    as geo; // Usando alias para evitar colisiones
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MapState {
  final bool isLoading;
  final List<LugaresMapaState> searchResults;
  final String searchQuery;
  final Point? currentLocation;
  final Point? selectedLocation;

  MapState({
    this.isLoading = false,
    this.searchResults = const [],
    this.searchQuery = '',
    this.currentLocation,
    this.selectedLocation,
  });

  MapState copyWith({
    bool? isLoading,
    List<LugaresMapaState>? searchResults,
    String? searchQuery,
    Point? currentLocation,
    Point? selectedLocation,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      currentLocation: currentLocation ?? this.currentLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }
}

// El provider sigue igual
final mapasProviders =
    StateNotifierProvider<MapasNotifierController, MapState>((ref) {
  final notifier = MapasNotifierController();
  // Importante: Manejar la disposición para cancelar el stream de ubicación
  ref.onDispose(() {
    notifier.dispose();
  });
  return notifier;
});

class MapasNotifierController extends StateNotifier<MapState> {
  MapboxMap? _mapboxMap;
  StreamSubscription<geo.Position>? _positionStreamSubscription;
  final Dio _dio = Dio(); // Usar una instancia de Dio
  PointAnnotationManager? _pointAnnotationManager;
  PointAnnotation? _currentMarker;
  MapasNotifierController() : super(MapState()) {
    // Puedes iniciar la solicitud de permisos/ubicación aquí o llamando a un método desde la UI
    // requestLocationPermissionAndStartUpdates();
    _initializePointAnnotationManager();
  }

  Future<void> _initializePointAnnotationManager() async {
    _pointAnnotationManager =
        await _mapboxMap?.annotations.createPointAnnotationManager();
  }

  /// Crea o reemplaza un marcador en la ubicación especificada
  Future<void> crearOReemplazarMarcador(double lng, double lat) async {
    if (_mapboxMap == null) {
      return;
    }

    // Inicializa el gestor de anotaciones si aún no existe
    if (_pointAnnotationManager == null) {
      await _initializePointAnnotationManager();
    }

    // Carga la imagen para el marcador (puedes reemplazar esto con tu propio asset)
    ByteData bytes;
    try {
      bytes = await rootBundle.load('assets/red_marker.png');
    } catch (e) {
      const size = 100;
      const halfSize = size ~/ 2;

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);

// Dibuja un pin en lugar de un círculo
      final paint = Paint()..color = Colors.blue;
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

// Dibuja sombra
      canvas.drawCircle(Offset(halfSize.toDouble(), halfSize.toDouble() + 2),
          halfSize * 0.8, shadowPaint);

// Dibuja el cuerpo del pin
      Path pinPath = Path()
        ..moveTo(halfSize.toDouble(), size.toDouble())
        ..lineTo(halfSize * 0.6, halfSize * 1.2)
        ..arcTo(
            Rect.fromCircle(
                center: Offset(halfSize.toDouble(), halfSize.toDouble()),
                radius: halfSize * 0.8),
            0.4 * pi,
            1.2 * pi,
            false)
        ..lineTo(halfSize.toDouble(), size.toDouble())
        ..close();

      canvas.drawPath(pinPath, paint);

// Dibuja un círculo en el centro del pin
      final centerPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(halfSize.toDouble(), halfSize.toDouble()),
          halfSize * 0.5, centerPaint);

      final picture = recorder.endRecording();
      final img = await picture.toImage(size, size);
      final pngBytes = await img.toByteData(format: ImageByteFormat.png);

      bytes = pngBytes!;
    }

    final Uint8List imageData = bytes.buffer.asUint8List();

    // Crea las opciones para el marcador
    PointAnnotationOptions pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        image: imageData,
        iconSize: 1.0);

    // Si ya existe un marcador, elimínalo
    // if (_currentMarker != null) {
    //   await _pointAnnotationManager?.delete(_currentMarker!);
    // }

    try {
      if (_currentMarker != null && _pointAnnotationManager != null) {
        _pointAnnotationManager?.delete(_currentMarker!);
      }
    } catch (e) {
      debugPrint('Error al eliminar anotación: $e');
    }

    // Crea el nuevo marcador
    _currentMarker =
        await _pointAnnotationManager?.create(pointAnnotationOptions);
  }

/*


 */

  // Método para limpiar recursos, especialmente el StreamSubscription
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose(); // Llama al dispose de StateNotifier si es necesario
    if (_pointAnnotationManager != null && _mapboxMap != null) {
      _mapboxMap!.annotations.removeAnnotationManager(_pointAnnotationManager!);
    }
  }

  void setMapboxMap(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    // Una vez que el mapa está listo, podríamos querer iniciar las actualizaciones de ubicación
    // o aplicar configuraciones iniciales del LocationComponent si es necesario.
    // Por ejemplo, aplicar el estado guardado si existiera.
    // applyInitialLocationSettings(); // Método hipotético
  }

  // --- Actualización y Gestión de Ubicación ---

  Future<bool> _checkAndRequestPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
    }
    return status.isGranted;
  }

  /// Solicita permisos y comienza a escuchar actualizaciones de ubicación.
  Future<void> requestLocationPermissionAndStartUpdates() async {
    final hasPermission = await _checkAndRequestPermission();
    if (!hasPermission || _mapboxMap == null) {
      return;
    }

    try {
      // Habilitar el componente de ubicación en Mapbox
      await _mapboxMap!.location
          .updateSettings(LocationComponentSettings(enabled: true));

      // Obtener la posición inicial
      geo.Position initialPosition = await geo.Geolocator.getCurrentPosition(
          desiredAccuracy: geo.LocationAccuracy.high);
      _updateLocationStateAndMap(initialPosition,
          flyToLocation: true); // Centra en la primera ubicación

      // Detener cualquier stream anterior antes de iniciar uno nuevo
      await _positionStreamSubscription?.cancel();

      // Configurar el stream de ubicación
      const locationSettings = geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10, // Actualizar cada 10 metros
      );

      _positionStreamSubscription =
          geo.Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((geo.Position position) {
        // Actualizar estado y (opcionalmente) el mapa con cada nueva posición
        _updateLocationStateAndMap(position,
            flyToLocation: false); // No centrar en cada actualización
      }, onError: (error) {
        print("Error en el stream de ubicación: $error");
        // Considera detener las actualizaciones o manejar el error
        stopLocationUpdates();
      });
    } catch (e) {
      print("Error al iniciar actualizaciones de ubicación: $e");
      // Podrías querer deshabilitar el componente de ubicación si falla
      _mapboxMap?.location
          .updateSettings(LocationComponentSettings(enabled: false));
    }
  }

  /// Actualiza el estado interno y opcionalmente mueve la cámara del mapa.
  void _updateLocationStateAndMap(geo.Position position,
      {bool flyToLocation = false}) {
    if (_mapboxMap == null) return;

    final newLocationPoint =
        Point(coordinates: Position(position.longitude, position.latitude));

    // Actualiza el estado de Riverpod
    state = state.copyWith(currentLocation: newLocationPoint);

    // Mueve la cámara si se especifica (generalmente solo la primera vez)
    if (flyToLocation) {
      centerOnCurrentLocation();
    }
    // NOTA: No necesitas llamar a `_mapboxMap.location.updateSettings` aquí para la posición,
    // el LocationComponent de Mapbox debería usar el proveedor de ubicación interno
    // una vez que está `enabled: true`. El `currentLocation` en tu `MapState` es para
    // tu lógica de app (como la proximidad en búsquedas).
  }

  /// Detiene las actualizaciones de ubicación.
  Future<void> stopLocationUpdates() async {
    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    // Opcionalmente, ocultar el puck de ubicación
    // setLocationComponentEnabled(false);
    print("Actualizaciones de ubicación detenidas.");
  }

  /// Centra el mapa en la última ubicación conocida guardada en el estado.
  Future<void> centerOnCurrentLocation() async {
    if (_mapboxMap != null && state.currentLocation != null) {
      await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(
                coordinates: state
                    .currentLocation!.coordinates), // Usa Point.coordinates
            // zoom: 15.0,
            zoom: 17,
            // Opcional: resetear bearing o pitch si se desea
            // bearing: 0,
            // pitch: 0,
          ),
          MapAnimationOptions(duration: 1500)); // Duración de la animación
    } else {
      print("No se puede centrar: Mapa no listo o ubicación desconocida.");
      // Podrías intentar obtener la ubicación si no existe
      // await requestLocationPermissionAndStartUpdates();
    }
  }

  /// Cambia la ubicación actual en el estado y opcionalmente centra el mapa en ella.
  Future<void> cambiarUbicacionActual(double lng, double lat) async {
    if (_mapboxMap == null) {
      print("Mapa no inicializado.");
      return;
    }

    final nuevaUbicacion = Point(coordinates: Position(lng, lat));

    // Actualiza el estado con la nueva ubicación
    state = state.copyWith(currentLocation: nuevaUbicacion);

    // Crea o reemplaza el marcador
    await crearOReemplazarMarcador(lng, lat);

    // Opcionalmente centra el mapa en la nueva ubicación
    await _mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: nuevaUbicacion.coordinates),
        zoom: 17.8,
      ),
      MapAnimationOptions(duration: 1500),
    );
    // if (flyToLocation) {
    // }
  }

  // --- Métodos de Control del LocationComponent (Basados en el Ejemplo) ---

  /// Habilita o deshabilita el componente de ubicación (puck, precisión, etc.).
  Future<void> setLocationComponentEnabled(bool enabled) async {
    await _mapboxMap?.location
        .updateSettings(LocationComponentSettings(enabled: enabled));
    // Opcional: Actualizar el estado si tienes flags
    // state = state.copyWith(isLocationPuckVisible: enabled);
  }

  /// Muestra u oculta el indicador de rumbo (bearing) del puck.
  Future<void> setPuckBearingEnabled(bool enabled) async {
    await _mapboxMap?.location
        .updateSettings(LocationComponentSettings(puckBearingEnabled: enabled));
    // Opcional: Actualizar el estado si tienes flags
    // state = state.copyWith(isBearingEnabled: enabled);
  }

  /// Muestra u oculta el anillo de precisión.
  Future<void> setShowAccuracyRing(bool show) async {
    await _mapboxMap?.location
        .updateSettings(LocationComponentSettings(showAccuracyRing: show));
  }

  /// Habilita o deshabilita la animación de pulso alrededor del puck.
  Future<void> setPulsingEnabled(bool enabled) async {
    await _mapboxMap?.location
        .updateSettings(LocationComponentSettings(pulsingEnabled: enabled));
  }

  /// Cambia el color del anillo de precisión.
  Future<void> setAccuracyRingColor(Color color) async {
    await _mapboxMap?.location.updateSettings(
        LocationComponentSettings(accuracyRingColor: color.value));
  }

  /// Cambia el color del borde del anillo de precisión.
  Future<void> setAccuracyRingBorderColor(Color color) async {
    await _mapboxMap?.location.updateSettings(
        LocationComponentSettings(accuracyRingBorderColor: color.value));
  }

  /// Cambia el color de la animación de pulso.
  Future<void> setPulsingColor(Color color) async {
    await _mapboxMap?.location
        .updateSettings(LocationComponentSettings(pulsingColor: color.value));
  }

  /// Cambia el indicador de ubicación a un puck 2D personalizado.
  /// [imagePath] debe ser la ruta a tu imagen en los assets (ej: 'assets/symbols/custom-icon.png')
  Future<void> setPuckTo2D(String imagePath) async {
    if (_mapboxMap == null) return;
    try {
      final ByteData bytes = await rootBundle.load(imagePath);
      final Uint8List list = bytes.buffer.asUint8List();

      await _mapboxMap!.location.updateSettings(LocationComponentSettings(
          locationPuck: LocationPuck(
              locationPuck2D: DefaultLocationPuck2D(
                  // Puedes añadir una imagen de sombra si la tienes
                  topImage: list,
                  shadowImage: Uint8List.fromList([]) // Imagen de sombra vacía
                  ))));
      print("Puck cambiado a 2D con imagen: $imagePath");
    } catch (e) {
      print("Error al cargar la imagen para el puck 2D: $e");
    }
  }

  /// Cambia el indicador de ubicación a un modelo 3D.
  /// [modelUri] puede ser una URL (http://...) o un asset local (asset://...).
  /// [scale] es un multiplicador para el tamaño del modelo.
  Future<void> setPuckTo3D(
      {required String modelUri, double scale = 1.0}) async {
    if (_mapboxMap == null) return;
    await _mapboxMap!.location.updateSettings(LocationComponentSettings(
        locationPuck: LocationPuck(
            locationPuck3D: LocationPuck3D(modelUri: modelUri, modelScale: [
      scale,
      scale,
      scale
    ] // Aplica la escala uniformemente
                ))));
    print("Puck cambiado a 3D con modelo: $modelUri y escala: $scale");
  }

  /// Actualiza la escala de un modelo 3D existente.
  /// Asume que el modelo 3D ya está configurado y solo cambia su escala.
  /// Requiere conocer el `modelUri` actual para no perderlo.
  Future<void> updatePuck3DScale(double newScale,
      {required String currentModelUri}) async {
    if (_mapboxMap == null) return;
    // Necesitamos re-aplicar toda la configuración del LocationPuck3D
    await _mapboxMap!.location.updateSettings(LocationComponentSettings(
        locationPuck: LocationPuck(locationPuck3D: LocationPuck3D(
            modelUri: currentModelUri, // Re-especifica el URI del modelo
            modelScale: [newScale, newScale, newScale]))));
    print("Escala del puck 3D actualizada a: $newScale");
  }

  /// Obtiene y muestra (en consola o snackbar) la configuración actual del LocationComponent.
  Future<void> printCurrentLocationSettings() async {
    if (_mapboxMap == null) {
      print("Mapa no inicializado.");
      return;
    }
    try {
      final settings = await _mapboxMap!.location.getSettings();
      print("""
        --- Location Component Settings ---
        Enabled: ${settings.enabled}
        Puck Bearing Enabled: ${settings.puckBearingEnabled}
        Puck Bearing: ${settings.puckBearing}
        Pulsing Enabled: ${settings.pulsingEnabled}
        Pulsing Color: ${settings.pulsingColor} (int value)
        Pulsing Radius: ${settings.pulsingMaxRadius}
        Show Accuracy Ring: ${settings.showAccuracyRing}
        Accuracy Ring Color: ${settings.accuracyRingColor} (int value)
        Accuracy Ring Border Color: ${settings.accuracyRingBorderColor} (int value)
        Location Puck Type: ${settings.locationPuck.runtimeType}
        ---------------------------------
        """);
      // Aquí podrías usar ScaffoldMessenger para mostrar un SnackBar si tienes el BuildContext
    } catch (e) {
      print("Error al obtener la configuración de ubicación: $e");
    }
  }

  // --- Funciones de Búsqueda (Sin cambios en endpoints) ---

  Future<void> searchPlaces(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: [], searchQuery: '');
      return;
    }

    state = state.copyWith(isLoading: true, searchQuery: query);

    try {
      final proximity = state.currentLocation != null
          ? '${state.currentLocation!.coordinates.lng},${state.currentLocation!.coordinates.lat}' // Correcto orden para Mapbox API
          : '';

      // Endpoint de Suggest (sin cambios)
      final url = Uri.parse(
          'https://api.mapbox.com/search/searchbox/v1/suggest?q=${Uri.encodeComponent(query)}&language=es&proximity=$proximity&access_token=$ACCESS_TOKEN'); // Añadido language=es y encode

      final response = await _dio.getUri(url); // Usando Dio

      if (response.statusCode == 200) {
        // La respuesta de Dio ya suele estar decodificada si es JSON
        final data = response.data;
        final suggestions =
            data['suggestions'] as List? ?? []; // Asegurar que es una lista

        // Usar Future.wait para esperar todas las llamadas a _getPlaceDetails
        final List<Future<LugaresMapaState?>> futurePlaces =
            suggestions.map<Future<LugaresMapaState?>>((suggestion) {
          final featureId = suggestion['feature_id'] as String?;
          if (featureId != null && featureId.isNotEmpty) {
            return _getPlaceDetails(featureId);
          } else {
            // Si no hay feature_id, retorna un futuro completado con null
            return Future.value(null);
          }
        }).toList();

        final resolvedPlacesResults = await Future.wait(futurePlaces);

        // Filtrar los resultados nulos (aquellos sin feature_id o con errores en _getPlaceDetails)
        final List<LugaresMapaState> validPlaces = resolvedPlacesResults
            .where((place) => place != null)
            .cast<LugaresMapaState>()
            .toList();

        state = state.copyWith(
          searchResults: validPlaces,
          isLoading: false,
        );
      } else {
        print(
            "Error en Suggest API: ${response.statusCode} ${response.statusMessage}");
        state = state.copyWith(
            isLoading: false, searchResults: []); // Limpiar resultados en error
      }
    } catch (e) {
      print("Error buscando lugares (Suggest): $e");
      if (e is DioException) {
        // Mejor manejo de errores de Dio
        print("DioError: ${e.response?.data}");
      }
      state = state.copyWith(isLoading: false, searchResults: []);
    }
  }

  Future<LugaresMapaState?> _getPlaceDetails(String featureId) async {
    if (featureId.isEmpty) return null;

    try {
      // Endpoint de Retrieve (sin cambios)
      final url = Uri.parse(
          'https://api.mapbox.com/search/searchbox/v1/retrieve/$featureId?access_token=$ACCESS_TOKEN');

      final response = await _dio.getUri(url); // Usando Dio

      if (response.statusCode == 200) {
        final data = response.data;
        // La respuesta de Retrieve tiene una estructura diferente a Suggest
        final feature =
            data['features'] as List?; // Es una lista con un solo feature
        if (feature != null && feature.isNotEmpty) {
          // Pasar el primer (y único) feature a fromJson
          return LugaresMapaState.fromJson(feature[0] as Map<String, dynamic>);
        } else {
          print("Respuesta de Retrieve no contiene 'features'.");
          return null;
        }
      } else {
        print(
            "Error en Retrieve API: ${response.statusCode} ${response.statusMessage}");
        return null;
      }
    } catch (e) {
      print("Error obteniendo detalles del lugar (Retrieve): $e");
      if (e is DioException) {
        print("DioError: ${e.response?.data}");
      }
      return null;
    }
  }

  void navigateToPlace(LugaresMapaState place) {
    if (_mapboxMap != null) {
      final point =
          Point(coordinates: Position(place.longitude, place.latitude));

      _mapboxMap!.flyTo(
          CameraOptions(
            // center: point.coordinates,
            center: Point(coordinates: point.coordinates),
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 2000));

      // Actualiza el estado para indicar la ubicación seleccionada
      state = state.copyWith(
          selectedLocation: point,
          searchResults: [],
          searchQuery: ''); // Limpia búsqueda después de seleccionar
    }
  }

  void clearSearch() {
    state = state.copyWith(searchResults: [], searchQuery: '');
  }
}
