import 'package:app_viaje_seguro/mapas/eventos/paciente_notifier_evento.dart';
import 'package:app_viaje_seguro/mapas/mapas_controller.dart';
import 'package:app_viaje_seguro/pages/page_index/notificaciones_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapaLocationPacientesState();
}

class _MapaLocationPacientesState extends ConsumerState<MapScreen> {
  late MapasNotifierController _mapNotifier;
  final TextEditingController _searchController = TextEditingController();

  // @override
  // void initState() {
  //   super.initState();
  //   // Obtenemos la instancia del notifier al iniciar el estado
  //   _mapNotifier = ref.read(mapasProviders.notifier);
  //   // Podrías añadir un listener al searchController si quieres búsqueda en tiempo real (con debounce)
  // }

  @override
  void initState() {
    super.initState();
    _mapNotifier = ref.read(mapasProviders.notifier);
  }

  @override
  void dispose() {
    // Limpiamos el controlador del TextField al destruir el estado
    _searchController.dispose();
    super.dispose();
  }

  // Callback para cuando el MapWidget está listo
  void _onMapCreated(MapboxMap mapboxMap) {
    // Informamos al notifier sobre la instancia del mapa
    _mapNotifier.setMapboxMap(mapboxMap);
    // Solicitamos permisos e iniciamos la ubicación y el centrado inicial
    _mapNotifier.requestLocationPermissionAndStartUpdates().catchError((e) {
      // Manejo básico de errores si falla la inicialización
      if (mounted) {
        // Comprueba si el widget sigue montado
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error al iniciar mapa: ${e.toString()}"),
          backgroundColor: Colors.red,
        ));
      }
    });
  }

  // Función para ejecutar la búsqueda
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _mapNotifier.searchPlaces(query);
      FocusScope.of(context).unfocus(); // Oculta el teclado
    } else {
      // Si la búsqueda está vacía, limpia los resultados
      _mapNotifier.clearSearch();
    }
  }

  // Función para limpiar el campo de búsqueda y los resultados
  void _clearSearchField() {
    _searchController.clear();
    _mapNotifier.clearSearch();
    FocusScope.of(context).unfocus(); // Oculta el teclado
    // Necesario para actualizar la UI (por ejemplo, el icono de limpiar) si no hay watch directo
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en la ubicación del paciente
    ref.listen(
      patientLocationStreamProvider(
          ref.read(selectedNotificacionesPacienteProvider).id.toString()),
      (previous, next) {
        if (next != null) {
          _mapNotifier.cambiarUbicacionActual(
            next.latitude,
            next.longitude,
          );
        }
      },
    );

    // Observamos el estado del mapa para reaccionar a cambios (isLoading, searchResults)
    final mapState = ref.watch(mapasProviders);
    final bool showClearButton = _searchController.text.isNotEmpty;
    final selectPaciente = ref.watch(selectedNotificacionesPacienteProvider);
    final textTheme = ShadTheme.of(context).textTheme;

    final locationNew =
        ref.watch(patientLocationStreamProvider(selectPaciente.id.toString()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación Paciente'),
        // Puedes añadir más acciones si necesitas
      ),
      body: Column(
        children: [
          const SizedBox(
            width: double.maxFinite,
            child: ChangePacientesByFamiliar(),
          ),
          Expanded(
            child: Stack(
              // Usamos Stack para superponer elementos sobre el mapa
              children: [
                // --- Widget del Mapa ---
                MapWidget(
                  key: const ValueKey("pacientesMap"),
                  onMapCreated: _onMapCreated,
                ),
                if (selectPaciente.id == 0)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.8), // Fondo semitransparente
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          // decoration: BoxDecoration(
                          //   color: Colors.white,
                          //   borderRadius: BorderRadius.circular(8.0),
                          // ),
                          child: Text(
                              'Selecciona un paciente para intentar buscar su ubicación.',
                              textAlign: TextAlign.center,
                              style: textTheme.h2.copyWith(
                                height: 0,
                                fontSize: 18,
                              )),
                        ),
                      ),
                    ),
                  ),
                // --- Mensaje de Selección de Paciente ---

                // --- Indicador de Carga ---
                if (mapState.isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),

                // --- Lista de Resultados de Búsqueda ---
                // Se muestra solo si hay resultados y no está cargando
                if (mapState.searchResults.isNotEmpty && !mapState.isLoading)
                  Positioned(
                    top:
                        75, // Ajusta esta posición debajo de la barra de búsqueda
                    left: 10,
                    right: 10,
                    // Limita la altura de la lista para no cubrir todo el mapa
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height *
                            0.4, // 40% de la altura
                      ),
                      child: Material(
                        elevation: 4.0,
                        borderRadius: BorderRadius.circular(8.0),
                        child: ListView.builder(
                          shrinkWrap:
                              true, // Ajusta la altura al contenido (dentro de ConstrainedBox)
                          itemCount: mapState.searchResults.length,
                          itemBuilder: (context, index) {
                            final place = mapState.searchResults[index];
                            return ListTile(
                              leading: const Icon(Icons.pin_drop_outlined),
                              title: Text(place.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(place.address,
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              onTap: () {
                                // Llama al notifier para navegar al lugar seleccionado
                                _mapNotifier.navigateToPlace(place);
                                // Limpia la búsqueda después de seleccionar
                                _clearSearchField();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // --- Botón Flotante para Centrar ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mapNotifier.cambiarUbicacionActual(
          locationNew?.latitude ?? 0.0,
          locationNew?.longitude ?? 0.0,
        ),
        tooltip: 'Centrar en mi ubicación',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
