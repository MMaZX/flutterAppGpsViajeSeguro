import 'package:app_viaje_seguro/config/theme.dart';
import 'package:app_viaje_seguro/controller/incidencias_controller.dart';
import 'package:app_viaje_seguro/controller/vehiculo_controller.dart';
import 'package:app_viaje_seguro/model/incidencias_model.dart';
import 'package:app_viaje_seguro/pages/maps.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/pages/vehiculos_registrar.dart';
import 'package:app_viaje_seguro/provider/geolocator_provider.dart';
import 'package:app_viaje_seguro/provider/theme_cubit.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class MapRestoreWidget extends ConsumerStatefulWidget {
  final int dniConductor;
  final LatLng coordinates;
  final String adress;

  const MapRestoreWidget(
      {super.key,
      required this.dniConductor,
      required this.adress,
      required this.coordinates});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MapRestoreWidgetState();
}

class _MapRestoreWidgetState extends ConsumerState<MapRestoreWidget> {
  // List<LatLng> model = [];
  final mapController = MapController();

  bool showLocationMovement = false;
  bool showCenterMovement = false;

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  final Color _colorDefault = Colors.white;
  @override
  Widget build(BuildContext context) {
    final gpsPositions = ref.watch(getLocationStatusStreamProvider);
    final userModel = ref.watch(getUserModelValuesProvider);
    return Scaffold(
      body: gpsPositions.when(
        data: (data) {
          double lat = widget.coordinates.latitude;
          double log = widget.coordinates.longitude;

          final locationNow = LatLng(data.$1, data.$2);
          final locationFinal = LatLng(lat, log);

          try {
            if (showLocationMovement) {
              mapController.move(locationNow, 15, offset: const Offset(0, 0));
            }

            if (showCenterMovement) {
              showLocationMovement = true;
              mapController.fitCamera(
                CameraFit.bounds(
                  maxZoom: 20,
                  bounds: LatLngBounds(
                    locationNow,
                    locationFinal,
                  ),
                  padding: const EdgeInsets.all(50),
                ),
              );
            }

            return PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) {
                  showDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text("Estado"),
                      content: const Text("¿Desea salir de la navegación?"),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text("Cancelar"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          child: const Text("Aceptar"),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  );
                }
              },
              child: SafeArea(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                          initialCenter: locationNow,
                          initialZoom: 18,
                          onTap: (tapPosition, point) {
                            ref.read(listMarketContainerProvider).add(point);
                          }),
                      children: [
                        openStreetMapTileLayer,
                        // const MarketCustomList(),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 15,
                              height: 15,
                              point: locationNow,
                              alignment: Alignment.center,
                              rotate: true,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.6),
                                      spreadRadius: 3,
                                      blurRadius: 10,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: locationFinal,
                              child: const Icon(Icons.location_on,
                                  color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                        //
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: [
                                locationNow,
                                locationFinal
                              ], // Puntos para dibujar la línea
                              strokeWidth: 4.0,
                              color: Colors.green, // Color de la línea
                            ),
                          ],
                        ),
                      ],
                    ),
                    //TERMINA EL MAPA
                    Positioned(
                      bottom: 30,
                      right: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FloatingActionButton(
                            heroTag: 'add_marker',
                            onPressed: () {
                              ref.invalidate(listMarketContainerProvider);
                              showModalBottomSheet(
                                context: context,
                                isDismissible: false,
                                enableDrag: false,
                                useSafeArea: true,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return const SizedBox(
                                      height: double.maxFinite,
                                      child: _DialogCoordinatesMarker());
                                },
                              );
                            },
                            backgroundColor: Colors.green,
                            child: const Icon(Icons.add_location),
                          ),
                          10.he,
                          const EndTravelButtonMap(),
                        ],
                      ),
                    ),

                    Container(
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade700,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.travel_explore_rounded,
                                color: _colorDefault,
                              ),
                              title: Text(
                                "Viajando a...",
                                style: TextStyle(
                                  color: _colorDefault,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                widget.adress,
                                style: TextStyle(
                                  color: _colorDefault,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  tooltip: "Centrar el marcador",
                                  onPressed: () {
                                    setState(() {
                                      showLocationMovement = true;
                                    });
                                  },
                                  icon: const Icon(Icons.my_location),
                                ),
                                IconButton(
                                  tooltip: "NO CENTRAR el marcador",
                                  onPressed: () {
                                    setState(() {
                                      showLocationMovement = false;
                                    });
                                  },
                                  icon: const Icon(Icons.gps_off_rounded),
                                ),
                              ],
                            )
                          ],
                        )),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: MaterialButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return _DialogConductorData(
                                  dniConductor: widget.dniConductor);
                            },
                          );
                        },
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text(
                          "Información del conductor",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    //FIN DEL STACK
                  ],
                ),
              ),
            );
          } catch (e) {
            return Container(
              child: Text("Exception: $e"),
            );
          }
        },
        error: (error, stackTrace) {
          return Text("ERROR: $error");
        },
        loading: () {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _DialogConductorData extends StatelessWidget {
  final int dniConductor;
  const _DialogConductorData({super.key, required this.dniConductor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        10.he,
        // ListTile(
        //   title: Text("Información del conductor"),
        // ),
        Expanded(
          child: FutureCustomWidget(
            future: VehiculoController(context: context)
                .getVehiculosIncidencias(dniConductor),
            widgetBuilder: (context, snapshot) {
              final item = snapshot.data;
              return ListView(
                children: [
                  ListTile(
                    title: const Text("Nombres completos",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['nombre_completo'].toString()),
                  ),
                  ListTile(
                    tileColor: Colors.redAccent.shade700,
                    title: const Text("Numero de incidencias",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text(
                      item['cant_incidencias'].toString(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: const Text("DNI",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      item['dni'].toString(),
                    ),
                  ),
                  ListTile(
                    title: const Text("Celular",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      item['celular'].toString(),
                    ),
                  ),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}

class _DialogCoordinatesMarker extends ConsumerStatefulWidget {
  const _DialogCoordinatesMarker();
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __DialogCoordinatesMarkerState();
}

class __DialogCoordinatesMarkerState
    extends ConsumerState<_DialogCoordinatesMarker> {
  // Lista original de incidencias
  final List<String> _availableIncidences = [
    'El viaje demoró más de lo esperado.',
    'Se pasó la luz roja.',
    'No respetó los paraderos.',
    'La apariencia del conductor es inadecuada, no da seguridad.',
    'El vehículo estaba sucio.',
    'Mal comportamiento del conductor o cobrador.',
  ];

  // Lista de incidencias seleccionadas
  final List<String> _selectedIncidences = [];

  void _incidenceSelectedModel(String incidence) {
    setState(() {
      if (_selectedIncidences.contains(incidence)) {
        _selectedIncidences.remove(incidence);
      } else {
        _selectedIncidences.add(incidence);
      }
    });
  }

  Color colorsSelected(String element, bool state) {
    if (_selectedIncidences.contains(element)) {
      return Colors.blueAccent;
    }
    return state ? Colors.black : Colors.white;
  }

  Color colorsTextSelected(String element, bool state) {
    if (_selectedIncidences.contains(element)) {
      return Colors.white;
    }
    return !state ? Colors.black : Colors.white;
  }

  TextEditingController comentarioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            children: [
              15.he,
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.location_on),
                title: const Text(
                  'Registrar Incidencia',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                    'Ubicación actual marcada.\nSelecciona una o varias incidencias.'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    isBackReturn(context);
                  },
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _availableIncidences.length,
                itemBuilder: (context, index) {
                  final incidence = _availableIncidences[index];
                  return MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onPressed: () => _incidenceSelectedModel(incidence),
                    color: colorsSelected(incidence, state),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        incidence,
                        style: TextStyle(
                            color: colorsTextSelected(incidence, state)),
                      ),
                    ),
                  );
                },
              ),
              //
              const Divider(
                height: 30,
              ),
              TextFormCustom(
                hintText: "Escribe un comentario (Opcional)",
                controller: comentarioController,
              ),
              const Divider(
                height: 30,
              ),
              const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Selecciona el conductor"),
                  subtitle: BuscarUsuarioPasajero()),
              ButtonCustomBase(
                onPressed: () {
                  final dni = ref.watch(usuarioSelectedVehiculoProvider);

                  final model = IncidenciasModel(
                      dni: dni,
                      comentario: comentarioController.text,
                      incidenciasArray: _selectedIncidences.toString());

                  IncidenciasController(context).createIncidencia(model);
                },
                title: "Registrar Incidencia",
              )
            ],
          ),
        );
      },
    );
  }
}

// class _DialogCoordinatesMarker extends StatefulWidget {
//   const _DialogCoordinatesMarker({
//     super.key,
//   });

//   @override
//   State<_DialogCoordinatesMarker> createState() =>
//       _DialogCoordinatesMarkerState();
// }

// class _DialogCoordinatesMarkerState extends State<_DialogCoordinatesMarker> {

// }

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.app',
    );

final listMarketContainerProvider = StateProvider<List<LatLng>>((ref) {
  return [];
});
