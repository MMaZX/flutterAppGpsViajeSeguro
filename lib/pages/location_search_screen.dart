import 'dart:async';

import 'package:app_viaje_seguro/config/socket.dart';
import 'package:app_viaje_seguro/controller/cloud_controller.dart';
import 'package:app_viaje_seguro/controller/incidencias_controller.dart';
import 'package:app_viaje_seguro/controller/vehiculo_controller.dart';
import 'package:app_viaje_seguro/model/vehiculo_model.dart';
import 'package:app_viaje_seguro/provider/geolocator_provider.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '/widgets/location_list_tile.dart';

class SearchLocationScreen extends ConsumerStatefulWidget {
  const SearchLocationScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SearchLocationScreenState();
}

class _SearchLocationScreenState extends ConsumerState<SearchLocationScreen> {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final suggestionsMapSearchBox =
        ref.watch(suggestionsMapSearchBoxProvider).features;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const ListTile(
              title: Text("¿A donde quieres viajar?"),
              subtitle: Text("Escribe un lugar al que quieras viajar"),
            ),
            TextFormCustom(
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () {
                  CloudController(ref: ref)
                      .getAutoCompleteMapsData(input: value);
                });
              },
              hintText: "Buscar una ubicación",
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: suggestionsMapSearchBox.length,
                    itemBuilder: (context, index) {
                      final item = suggestionsMapSearchBox[index];
                      return LocationListTile(
                        location: item.properties.fullAddress,
                        press: () async {
                          ref
                              .read(retrieveMapSearchBoxProvider.notifier)
                              .update((state) => item);

                          showDialog(
                            context: context,
                            builder: (ctx) => DialogVerAutosDisponibles(ctx),
                          );

                          // Navigator.pushAndRemoveUntil(
                          //     context,
                          //     CupertinoPageRoute(
                          //       builder: (context) => const MapFlutterWidget(),
                          //     ),
                          //     (route) => true);
                        },
                      );
                    })),
          ],
        ),
      ),
    );
  }
}

class DialogVerAutosDisponibles extends ConsumerStatefulWidget {
  final BuildContext ctx;
  const DialogVerAutosDisponibles(this.ctx, {super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DialogVerAutosDisponiblesState();
}

class _DialogVerAutosDisponiblesState
    extends ConsumerState<DialogVerAutosDisponibles> {
  late SocketController socket;
  @override
  void initState() {
    super.initState();
    socket = SocketController(ref: ref, context: widget.ctx);
    socket.connectedSocket();
  }

  BorderRadius radiusBorder = BorderRadius.circular(15);
  @override
  Widget build(BuildContext context) {
    final dataSelected = ref.watch(retrieveMapSearchBoxProvider);
    final query = MediaQuery.sizeOf(context);

    final positions = ref.watch(getLocationStatusStreamProvider);
    // final vehiculesActive = ref.watch(vehiculosActivesModulesProvider);
    return SizedBox(
      height: query.height * 0.7,
      child: ClipRRect(
        borderRadius: radiusBorder,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Dialog(
            child: Column(
              children: [
                const ListTile(
                  title: Text("Autos disponibles"),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: socket.getAllUsersConductores(),
                    builder: (context, snapshot) {
                      final model = snapshot.data;
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text("ERROR : ${snapshot.error}",
                              textAlign: TextAlign.center),
                        );
                      }

                      if (model == null) {
                        return const Center(
                          child: Text(
                            "Ha ocurrido un error al tratar de devolver algún valor del socket. Verifica la configuración",
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      final vehiculesActive = model;
                      if (vehiculesActive.isEmpty) {
                        return const Center(
                          child: Text("No existen conductores disponibles"),
                        );
                      }

                      return positions.when(
                        data: (data) {
                          double lat = data.$1;
                          double lng = data.$2;
                          LatLng latLogCurrent = LatLng(lat, lng);

                          return ListView.builder(
                            itemCount: vehiculesActive.length,
                            itemBuilder: (context, index) {
                              RetrieveLocationSocket item =
                                  vehiculesActive[index];
                              return ListTile(
                                leading: const Icon(Icons.car_crash),
                                onTap: () async {
                                  try {
                                    //NECESITAMOS SABER SI PUEDEN VIAJAR MAS PERSONAS LLAMAMOS A LA FUNCION:
                                    VehiculoSolicitudModel? model =
                                        await VehiculoController(
                                                context: context, ref: ref)
                                            .getAsientosDisponibles(
                                                int.parse(item.id.toString()));
                                    if (model == null) {
                                      throw Exception(
                                          "No se ha podido obtener la información del vehículo");
                                    }
                                    if (item.numAsientos ==
                                        model.numAsientosActivos) {
                                      throw Exception(
                                          "No hay asientos disponibles en este vehículo");
                                    }

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return _DialogSelectedAsientosUser(
                                          socket: socket,
                                          item: item,
                                          model: model,
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    showSnackbarCustom(context, e.toString());
                                  }
                                },
                                title: Text(item.nombreConductor.toString()),
                                subtitle: Text(
                                    "${item.rol} ${getDistance(item.latLogDefault, latLogCurrent).toStringAsFixed(2)} km"),
                              );
                            },
                          );
                        },
                        error: (error, stackTrace) {
                          return Center(
                            child: Text("ERROR : $error",
                                textAlign: TextAlign.center),
                          );
                        },
                        loading: () {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogSelectedAsientosUser extends StatefulWidget {
  final SocketController socket;
  final RetrieveLocationSocket item;
  final VehiculoSolicitudModel model;
  const _DialogSelectedAsientosUser({
    super.key,
    required this.socket,
    required this.item,
    required this.model,
  });

  @override
  State<_DialogSelectedAsientosUser> createState() =>
      _DialogSelectedAsientosUserState();
}

class _DialogSelectedAsientosUserState
    extends State<_DialogSelectedAsientosUser> {
  double _currentSliderValue = 1;

  @override
  Widget build(BuildContext context) {
    double asientosDisponibles =
        (widget.item.numAsientos - widget.model.numAsientosActivos)
            .roundToDouble();
    return Dialog(
      child: SizedBox(
        height: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    // contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Num. de asientos (DISPONIBLES) ${_currentSliderValue.round().toString()}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, height: 0),
                    ),
                    subtitle: asientosDisponibles < 2
                        ? const Text("\nQueda un asiento disponible")
                        : Slider(
                            value: _currentSliderValue,
                            min: 1, // Valor mínimo
                            max: asientosDisponibles,
                            divisions: asientosDisponibles.toInt() - 1,
                            label: _currentSliderValue.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                _currentSliderValue = value;
                              });
                            },
                            activeColor: Colors.blue,
                            inactiveColor: Colors.grey[300],
                          ),
                  ),
                  ButtonCustomBase(
                    onPressed: () {
                      widget.socket.sendSolicitud(
                          widget.item.id, _currentSliderValue.toInt());
                    },
                    title: "Enviar Solicitud",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
