import 'dart:async';

import 'package:app_viaje_seguro/config/api.dart';
import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/config/socket.dart';
import 'package:app_viaje_seguro/config/theme.dart';
import 'package:app_viaje_seguro/controller/cloud_controller.dart';
import 'package:app_viaje_seguro/controller/incidencias_controller.dart';
import 'package:app_viaje_seguro/model/prediction.dart';
import 'package:app_viaje_seguro/model/response_model.dart';
import 'package:app_viaje_seguro/model/vehiculo_model.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/provider/geolocator_provider.dart';
import 'package:app_viaje_seguro/provider/theme_cubit.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class VehiculoController {
  final BuildContext context;
  final WidgetRef? ref;
  VehiculoController({required this.context, this.ref});

  Dio dio = Dio();

/*
    Route::post('vehiculos/state/crear-reporte-viaje', 'crearReporteViaje');
    Route::post('vehiculos/state/actualizar-reporte-viaje-final-real', 'actualizarReporteViajeFinalReal');

 */
  Future<void> guardarVehiculoSolicitud(VehiculoSolicitudModel model) async {
    String path =
        Endpoint(context: context).getPath(ContentApi.guardarVehiculoSolicitud);
    try {
      final response = await dio.post(path, data: model.toMap());
      final json = response.data;
      showCustomSnackbar(context, json.toString());
    } on DioException catch (e) {
      throw Exception("Error al guardar vehiculo solicitud. ${e.response}");
    }
  }

  Future<void> closeSessionTravel({required int valoracion}) async {
    try {
      String path = Endpoint(context: context)
          .getPath(ContentApi.actualizarReporteViajeFinalReal);
      final userModel = await SharedToken().getLoginToken();
      final value = await Geolocator.getCurrentPosition();

      final model = {
        "dni_usuario": userModel.dni,
        "lng_final_real": value.longitude,
        "lat_final_real": value.latitude,
        "valoracion": valoracion,
      };
      final response = await dio.post(path, data: model);
      final json = response.data;

      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );
      }

      showCustomSnackbar(context, json.toString());
    } on DioException catch (e) {
      String message = e.response.toString();
      showSnackbarCustomCloseSession(context, message);
    }
  }

  Future<void> crearReporteViaje(ReporteViajeModel model) async {
    String path =
        Endpoint(context: context).getPath(ContentApi.crearReporteViaje);
    try {
      final response = await dio.post(path, data: model.toMapForCreate());
      final json = response.data;
      showCustomSnackbar(context, json.toString());
    } on DioException catch (e) {
      throw Exception("Error al crear reporte de viaje. ${e.response}");
    }
  }

  Future<dynamic> getVehiculosIncidencias(int dni) async {
    final path = Endpoint(context: context)
        .getPathById(ContentApi.vehiculosIncidencias, dni.toString());
    try {
      final response = await dio.get(path);
      final json = response.data;
      return json;
    } on DioException catch (e) {
      print(e.response.toString());
      return null;
      // throw Exception("Error al obtener las incidencias. ${e.response}");
    }
  }

  Future<void> updateFinalTravel(int dni, LatLng dataLng) async {
    String path = Endpoint(context: context)
        .getPath(ContentApi.actualizarReporteViajeFinalReal);
    Map<String, dynamic> model = {
      "dni_usuario": dni,
      "lng_final_real": dataLng.longitude,
      "lat_final_real": dataLng.latitude,
    };

    try {
      final response = await dio.post(path, data: model);
      final json = response.data;
      showCustomSnackbar(context, json.toString());
    } on DioException catch (e) {
      print(e.response);
      showCustomSnackbar(context, e.response.toString());
    }
  }

  Future<UserActiveModel> getActiveTravel(int dni, String estado) async {
    String path = Endpoint(context: context)
        .getPathById(ContentApi.vehiculosActivosBro, "$dni/$estado");
    try {
      final response = await dio.get(path);
      final json = response.data;
      final model = UserActiveModel.fromJson(json);
      return model;
    } on DioException catch (e) {
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => const SesionPage()),
        (route) => false,
      );
      return UserActiveModel.isEmpty();
    }
  }

  Future<VehiculoSolicitudModel?> getAsientosDisponibles(int dni) async {
    final path = Endpoint(context: context)
        .getPathById(ContentApi.asientosPorVehiculo, dni.toString());

    try {
      final response = await dio.get(path);
      final json = response.data;
      print(json);
      VehiculoSolicitudModel model = VehiculoSolicitudModel.toJson(json);
      return model;
    } on DioException catch (e) {
      throw Exception(
          "Error al obtener los asientos disponibles. ${e.response}");
    }
  }

  Future<ResponseModel> createVehiculo(VehiculoModel model) async {
    final path = Endpoint(context: context).getPath(ContentApi.vehiculos);
    try {
      final response = await dio.post(path, data: model.toJson());
      final json = response.data;
      return ResponseModel.fromData(json);
    } on DioException catch (e) {
      Map<String, dynamic> json = e.response?.data ?? {};
      return ResponseModel.fromData(json);
    }
  }

  Future<List<VehiculoModel>> getVehiculos() async {
    final path = Endpoint(context: context).getPath(ContentApi.vehiculos);
    try {
      final response = await dio.get(path);
      final json = response.data;
      List<VehiculoModel> list = [];
      for (var item in json) {
        list.add(VehiculoModel.fromJson(item));
      }
      return list;
    } on DioException catch (e) {
      Map<String, dynamic> json = e.response?.data ?? {};
      debugPrint(json.toString());
      return [];
    }
  }
}

class NotificationController {
  OverlayEntry? overlayEntry;
  final BuildContext context;

  NotificationController({
    this.overlayEntry,
    required this.context,
  });
  // Método para mostrar el Overlay
  Future<bool> showOverlayRequestConductor(
      String message, RetrieveLocationSocket modelUser) {
    Completer<bool> completer = Completer<bool>();
    _removeOverlay();
    overlayEntry = OverlayEntry(
        builder: (context) => _ContentWidget(
              modelUser: modelUser,
              message: message,
              onPressed: () {
                _removeOverlay();
                completer.complete(true);
              },
              onPressedExit: () {
                _removeOverlay();
                completer.complete(false);
              },
            ));

    // Insertar el overlay en el contexto actual
    Overlay.of(context).insert(overlayEntry!);
    return completer.future;
  }

  Future<bool> showOverlayRequestPasajero(
      String message, RetrieveLocationSocket modelUser) {
    Completer<bool> completer = Completer<bool>();
    _removeOverlay();
    overlayEntry = OverlayEntry(
        builder: (context) => _PasajeroWidgetContent(
              modelUser: modelUser,
              message: message,
              onPressed: () {
                _removeOverlay();
                completer.complete(true);
              },
              onPressedExit: () {
                _removeOverlay();
                completer.complete(false);
              },
            ));

    // Insertar el overlay en el contexto actual
    Overlay.of(context).insert(overlayEntry!);
    return completer.future;
  }

  // Método para eliminar el Overlay
  void _removeOverlay() {
    if (overlayEntry != null) {
      overlayEntry!.remove();
      overlayEntry = null;
    }
  }
}

void showCustomSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    // backgroundColor: Colors.transparent,
    // margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    padding: EdgeInsets.zero,
    content: BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return ListTile(
          title: Text(
            "Estado",
            style: TextStyle(
              color: state ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            message,
            style: TextStyle(
              color: state ? Colors.black : Colors.white,
              fontSize: 16,
            ),
          ),
        );
      },
    ),
    duration: const Duration(seconds: 3), // Duración del Snackbar
    behavior: SnackBarBehavior.fixed, // Comportamiento del Snackbar
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

// class _ContentWidget extends StatefulWidget {

//   @override
//   State<_ContentWidget> createState() => __ContentWidgetState();
// }

// class __ContentWidgetState extends State<_ContentWidget> {
//   @override
//   Widget build(BuildContext context) {

//   }
// }

class _ContentWidget extends ConsumerStatefulWidget {
  final String message;
  final Function() onPressed;
  final Function() onPressedExit;
  final RetrieveLocationSocket modelUser;
  const _ContentWidget({
    required this.message,
    required this.onPressed,
    required this.onPressedExit,
    required this.modelUser,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __ContentWidgetState();
}

class __ContentWidgetState extends ConsumerState<_ContentWidget> {
  @override
  Widget build(BuildContext context) {
    final positionNow = ref.watch(getLocationStatusStreamProvider);
    final _item = widget.modelUser;
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, themeState) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeApp.getLight(),
            darkTheme: ThemeApp.getDark(),
            themeMode: themeState ? ThemeMode.dark : ThemeMode.light,
            home: Scaffold(
              // backgroundColor: Colors.transparent,
              // backgroundColor: Theme.of(context).colorScheme.background,

              appBar: AppBar(
                actions: const [IconChangeTheme()],
              ),
              body: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Solicitud de viaje",
                      maxLines: 2,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(height: 0),
                    ),
                    const Spacer(),
                    positionNow.when(
                      data: (data) {
                        LatLng nowLocation = LatLng(data.$1, data.$2);

                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(
                            _item.nombreConductor.toString(),
                          ),
                          subtitle: Text(
                              "Distancia entre tu y el cliente: ${getDistance(_item.latLogDefault, nowLocation).toStringAsFixed(2)} km"),
                        );
                      },
                      error: (error, stackTrace) => ListTile(
                        title: const Text("Estado"),
                        subtitle: Text(error.toString()),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                    ),
                    ButtonCustomBase(
                      minWidth: double.maxFinite,
                      borderRadius: 10,
                      onPressed: widget.onPressedExit,
                      color: Colors.redAccent.shade700,
                      title: "Rechazar",
                      padding: EdgeInsets.zero,
                    ),
                    ButtonCustomBase(
                      padding: EdgeInsets.zero,
                      minWidth: double.maxFinite,
                      borderRadius: 10,
                      onPressed: widget.onPressed,
                      title: "Aceptar",
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final solicitudSocketProvider = StateProvider<SolicitudSocketModel>((ref) {
  return SolicitudSocketModel.isEmpty();
});

class _PasajeroWidgetContent extends ConsumerStatefulWidget {
  final String message;
  final Function() onPressed;
  final Function() onPressedExit;
  final RetrieveLocationSocket modelUser;
  const _PasajeroWidgetContent({
    required this.message,
    required this.onPressed,
    required this.onPressedExit,
    required this.modelUser,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      __PasajeroWidgetContentState();
}

class __PasajeroWidgetContentState
    extends ConsumerState<_PasajeroWidgetContent> {
  @override
  Widget build(BuildContext context) {
    final positionNow = ref.watch(getLocationStatusStreamProvider);
    final _item = widget.modelUser;

    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, themeState) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeApp.getLight(),
            darkTheme: ThemeApp.getDark(),
            themeMode: themeState ? ThemeMode.dark : ThemeMode.light,
            home: Scaffold(
              appBar: AppBar(
                actions: const [IconChangeTheme()],
              ),
              body: Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Esperando solciitud",
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Esperando confirmación del conductor",
                        textAlign: TextAlign.center,
                        style: TextStyle(height: 0),
                      ),
                      // const Spacer(),
                      // ButtonCustomBase(
                      //   minWidth: double.maxFinite,
                      //   borderRadius: 10,
                      //   onPressed: widget.onPressedExit,
                      //   color: Colors.redAccent.shade700,
                      //   title: "Rechazar",
                      //   padding: EdgeInsets.zero,
                      // ),
                      // ButtonCustomBase(
                      //   padding: EdgeInsets.zero,
                      //   minWidth: double.maxFinite,
                      //   borderRadius: 10,
                      //   onPressed: _item.numAsientos == _item.numAsientos
                      //       ? null
                      //       : widget.onPressed,
                      //   title: "Aceptar",
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
