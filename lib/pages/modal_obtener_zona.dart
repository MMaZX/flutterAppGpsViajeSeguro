import 'package:app_viaje_seguro/mapas/mapas_controller.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ModalObtenerZona extends ConsumerStatefulWidget {
  final Function(Point? point)
      onPointSelected; // Callback para devolver el punto
  const ModalObtenerZona({
    required this.onPointSelected,
    super.key,
  });

  @override
  ConsumerState<ModalObtenerZona> createState() =>
      _ModalObtenerZonaState(); // Cambio aquí
}

class _ModalObtenerZonaState extends ConsumerState<ModalObtenerZona> {
  Point?
      _selectedPoint; // Estado local para el punto seleccionado en ESTE modal
  late MapasNotifierController _mapNotifier;

  @override
  void initState() {
    super.initState();
    // Obtenemos la instancia del notifier una vez
    _mapNotifier = ref.read(mapasProviders.notifier);
  }

  // Se llama cuando el MapWidget está listo
  void _onMapCreated(MapboxMap mapboxMap) {
    // 1. Informa al notifier sobre la nueva instancia del mapa
    _mapNotifier.setMapboxMap(mapboxMap);

    // 2. Pide al notifier que inicie permisos, ubicación y centre el mapa
    _mapNotifier.requestLocationPermissionAndStartUpdates().catchError((e) {
      _showErrorSnackbar("Error al iniciar mapa y ubicación: $e");
    });

    // 3. (Opcional) Puedes aplicar configuraciones específicas para este modal
    // si necesitas anular temporalmente algo del notifier.
    // mapboxMap.location.updateSettings(LocationComponentSettings(...));
  }

  // Llama al método del notifier para centrar en la ubicación actual
  Future<void> _centerOnUserLocation() async {
    try {
      await _mapNotifier.centerOnCurrentLocation();
    } catch (e) {
      _showErrorSnackbar("No se pudo centrar en la ubicación: $e");
    }
  }

  // Helper para mostrar errores
  void _showErrorSnackbar(String message) {
    if (mounted) {
      // Verifica si el widget todavía está en el árbol
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Helper para mostrar información
  void _showInfoSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escucha el estado del notifier si necesitas reaccionar a cambios
    // final mapState = ref.watch(mapasProviders);

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)), // Bordes redondeados
      clipBehavior: Clip.antiAlias, // Para que el contenido respete los bordes
      child: Scaffold(
        body: Container(
          // Define un tamaño máximo o usa constraints
          width: MediaQuery.of(context).size.width * 0.9, // 90% del ancho
          height: MediaQuery.of(context).size.height * 0.8, // 70% del alto
          constraints: const BoxConstraints(
            maxWidth: 600, // Límite máximo de ancho
            maxHeight: 800, // Límite máximo de alto
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta al contenido verticalmente
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 16.0), // Más padding vertical
                child: Text(
                  "Selecciona una ubicación",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                // El mapa ocupa el espacio restante
                child: Stack(
                  children: [
                    MapWidget(
                      key: const ValueKey("modalMapWidget"),
                      onMapCreated: _onMapCreated,
                      onTapListener: (interactionContext) {
                        final Point tappedPoint = interactionContext.point;
                        setState(() {
                          _selectedPoint = tappedPoint;
                        });
                        String ubicacionSeleccionada =
                            "Ubicación seleccionada: Lon: ${tappedPoint.coordinates.lng.toStringAsFixed(5)}, Lat: ${tappedPoint.coordinates.lat.toStringAsFixed(5)}";
                        showDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            title:
                                const Text("¿Deseas guardar esta ubicación?"),
                            content: Text(ubicacionSeleccionada),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text("Aceptar"),
                                onPressed: () async {
                                  isBackReturn(context);
                                  widget.onPointSelected(_selectedPoint);
                                  _showInfoSnackbar(ubicacionSeleccionada);

                                  // Espera 500 milisegundos y luego cierra todo
                                  isBackReturn(context);
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text("Cancelar"),
                                onPressed: () =>
                                    isBackReturn(context), // Cierra el diálogo
                              ),
                            ],
                          ),
                        );
                      },
                      // Puedes añadir otros listeners si los necesitas (onLongTapListener, etc.)
                    ),
                    // Botón flotante para centrar en la ubicación del usuario
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true, // Botón más pequeño
                        tooltip: "Centrar en mi ubicación",
                        onPressed: _centerOnUserLocation,
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                  ],
                ),
              ),
              // Fila de botones inferior
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: ShadButton.outline(
                  width: double.maxFinite,
                  onPressed: () => Navigator.of(context)
                      .pop(), // Cierra el diálogo sin seleccionar
                  child: const Expanded(
                      child: Text("Cancelar")), // Usa el parámetro 'text'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
