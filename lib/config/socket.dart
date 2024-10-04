import 'dart:async';
import 'dart:developer';
import 'package:app_viaje_seguro/config/api.dart';
import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/controller/controller_state.dart';
import 'package:app_viaje_seguro/controller/incidencias_controller.dart';
import 'package:app_viaje_seguro/controller/vehiculo_controller.dart';
import 'package:app_viaje_seguro/model/prediction.dart';
import 'package:app_viaje_seguro/model/request_model.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/model/vehiculo_model.dart';
import 'package:app_viaje_seguro/pages/conductor_page.dart';
import 'package:app_viaje_seguro/pages/esperando_page.dart';
import 'package:app_viaje_seguro/provider/geolocator_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';

class SocketController {
  final WidgetRef ref;
  final BuildContext context;
  SocketController({required this.ref, required this.context});

  // any getters

  static String socketurl = "http://192.168.1.22:3000";

  // String socketurl = "http://rutaapiportmap.portmap.io:37161";
  Socket socket = io(socketurl, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });

  // Inicializamos la lista de ese Stream
  List<RetrieveLocationSocket> userConnectedList = [];

  // INICIALIZAMOS EL STREAM
  final StreamController<List<RetrieveLocationSocket>> _controller =
      StreamController<List<RetrieveLocationSocket>>.broadcast();

  void connectedSocket() {
    socket.connect();
    socket.onConnect((_) {
      print('Connected and WS!!');
      _SocketFunctions(socket, context).userRegisterSocket();
      _SocketFunctions(socket, context).getSolicitudItem();
    });

    // DESCONECTAR EL SOCKET BB
    socket.onDisconnect((_) {
      print("Disconnected from WebSocket server");
      _SocketFunctions(socket, context).userRegisterSocket();
    });
  }

  Future<void> sendSolicitud(int dni, int numAsientos) async {
    final userModel = await SharedToken().getLoginToken();
    socket.emit('sendSolicitud', {
      'dni': dni,
      'numAsientos': numAsientos,
      'dnipasajero': int.parse(userModel.dni.toString())
    });
  }

  Stream<List<RetrieveLocationSocket>> getAllUsersConductores() {
    List<RetrieveLocationSocket> userConnectedList = [];
    socket.on("allUsersConnected", (data) {
      try {
        if (data is List<dynamic>) {
          userConnectedList.clear();
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              if (item['rol'] == 'PASAJERO') continue; // Saltar los pasajeros
              userConnectedList.add(RetrieveLocationSocket.fromJson(item));
            }
          }
          _controller.add(userConnectedList);
        }
      } catch (e) {
        log("ERROR ALLUSERCONNECTED: $e");
        _controller.addError(e);
      }
    });
    return _controller.stream;
  }
}

class _SocketFunctions {
  final Socket socket;
  final BuildContext context;

  _SocketFunctions(
    this.socket,
    this.context,
  );

  // función para devolver registrar un usuario en el evento "register" Stream
  Future<void> userRegisterSocket() async {
    try {
      // TRAER EL USUARIO ACTUAL
      final model = await SharedToken().getLoginToken();
      //VERIFICAMOS PERMISOS
      await GeoController().getGeolocatorPermission();
      // OBTENER LA UBICACION ACTUAL
      final locationStatus = Geolocator.getPositionStream();
      await for (Position positionData in locationStatus) {
        // OBTENER LATITUD Y LONGITUD
        String lat = positionData.latitude.toString();
        String lng = positionData.longitude.toString();

        // ENVIAR LA UBICACION AL SERVIDOR
        final item = RetrieveLocationSocket(
          id: int.parse(model.dni),
          lat: lat,
          lon: lng,
          rol: model.rol,
          nombreConductor: model.nombreCompleto,
          placa: model.placa.toString(),
          numAsientos: model.numAsientos == null
              ? 0
              : int.parse(model.numAsientos.toString()),
        );
        // print(item.toMap());
        socket.emit('register', item.toMap());
      }
    } catch (e) {
      log("ERROR REGISTER $e");
    }
  }

  // funcion para devolver la ubicación actual y enviarsela al evento "register" Future
  Future<void> userRegisterSocketFuture() async {
    try {
      // TRAER EL USUARIO ACTUAL
      final model = await SharedToken().getLoginToken();
      //VERIFICAMOS PERMISOS
      await GeoController().getGeolocatorPermission();
      // OBTENER LA UBICACION ACTUAL
      Position positionData = await Geolocator.getCurrentPosition();
      // OBTENER LATITUD Y LONGITUD
      String lat = positionData.latitude.toString();
      String lng = positionData.longitude.toString();

      // ENVIAR LA UBICACION AL SERVIDOR
      final item = RetrieveLocationSocket(
        id: int.parse(model.dni),
        lat: lat,
        lon: lng,
        rol: model.rol,
        nombreConductor: model.nombreCompleto,
      );
      socket.emit('register', item.toMap());
    } catch (e) {
      log("ERROR REGISTER FUTURE $e");
    }
  }

  // ENVIAR SOLICITUD DE VIAJE

  Future<void> getSolicitudItem() async {
    // Inicializamos el usuario actual y la variable booleana de aceptación
    UsuarioModel userModel = await SharedToken().getLoginToken();
    bool isAccepted = false;
    // LLAMAMOS AL CONTROLLER DE NOTIFICACIONES
    NotificationController notificationController =
        NotificationController(context: context);

    // Llamamos al evento "solicitud" del servidor
    socket.on('solicitud', (data) async {
      SolicitudSocketModel model = SolicitudSocketModel.fromJson(data);
      socket.emit('estadoSolicitudRespuesta', {
        'estado': SolicitudEstadoPasajero.waiting.index,
        'dni': model.dniPasajero,
      });
      try {
        // SI ES CONDUCTOR ENTONCES LE MANDAREMOS LA SOLICITUD
        if (userModel.rol == 'CONDUCTOR') {
          if (data is Map<String, dynamic>) {
            RetrieveLocationSocket? userSocketModel = model.user;
            if (model.dni != int.parse(userModel.dni.toString())) {
              return;
            }
            if (userSocketModel == null) {
              throw Exception(
                  "No se pudo recuperar la información del usuario");
            }

            // Mostrar overlay según la solicitud
            isAccepted = await notificationController
                .showOverlayRequestConductor(model.message, userSocketModel);

            if (isAccepted) {
              socket.emit('estadoSolicitudRespuesta', {
                'estado': SolicitudEstadoPasajero.accepted.index,
                'dni': model.dniPasajero,
              });
              final solicitudModel = VehiculoSolicitudModel(
                  dniUsuario: model.dni.toString(),
                  numAsientosActivos:
                      int.parse(model.numAsientosRequest.toString()),
                  estado: 0);
              await VehiculoController(context: context)
                  .guardarVehiculoSolicitud(solicitudModel);
                    // final userModel = await SharedToken().getLoginToken();
              final rol = userModel.rol;
              UserActiveModel status =
                  await VehiculoController(context: context)
                      .getActiveTravel(int.parse(userModel.dni), userModel.rol);
              log(status.toMap().toString());
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (context) =>  ConductorPage(
                  userActiveModel: status,
                )),
                (route) => false,
              );
            } else {
              socket.emit('estadoSolicitudRespuesta', {
                'estado': SolicitudEstadoPasajero.rejected.index,
                'dni': model.dniPasajero,
              });
            }
          }
        }
        if (userModel.rol == 'PASAJERO') {
          if (data is Map<String, dynamic>) {
            RetrieveLocationSocket? userSocketModel = model.user;
            if (model.dniPasajero != int.parse(userModel.dni.toString())) {
              return;
            }
            if (userSocketModel == null) {
              throw Exception(
                  "No se pudo recuperar la información del usuario");
            }
            socket.emit('estadoSolicitudRespuesta', {
              'estado': SolicitudEstadoPasajero.waiting.index,
              'dni': model.dniPasajero,
            });
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                  builder: (context) => EsperandoPage(
                        dniPasajero: model.dniPasajero,
                        dniConductor: model.dni,
                        numAsientos:
                            int.parse(model.numAsientosRequest.toString()),
                      )),
              (route) => false,
            );
            return;
          }
        }
      } catch (e) {
        showCustomSnackbar(context, e.toString());
      }
    });
  }
}

class SocketRequest {
  final BuildContext context;
  SocketRequest(this.context);

  Dio dio = Dio();

  Future<VehiculoModel>? getDataVehiculo(int dni) async {
    final path = Endpoint(context: context)
        .getPathById(ContentApi.vehiculosPorDNI, dni.toString());
    try {
      final response = await dio.get(path);
      final json = response.data;
      final model = VehiculoModel.fromGetDataJson(json);
      return model;
    } on DioException catch (e) {
      Map<String, dynamic> json = e.response?.data ?? {};
      showSnackbarCustom(context, json.toString());
      throw Exception("Error al obtener los datos del vehículo");
    }
  }
}

class SolicitudSocketModel {
  final bool value;
  final String message;
  final int dni;
  final int dniPasajero;
  final int? numAsientosRequest;
  final RetrieveLocationSocket? user;

  SolicitudSocketModel.isEmpty()
      : value = false,
        message = '',
        dni = 0,
        user = null,
        dniPasajero = 0,
        numAsientosRequest = 0;

  SolicitudSocketModel({
    required this.value,
    required this.message,
    required this.user,
    required this.numAsientosRequest,
    required this.dniPasajero,
    required this.dni,
  });
  factory SolicitudSocketModel.fromJson(Map<String, dynamic> json) {
    try {
      return SolicitudSocketModel(
        value: bool.parse(json['value'].toString()),
        message: json['message'].toString(),
        dni: int.parse(json['dni'].toString()),
        dniPasajero: int.parse(json['dnipasajero'].toString()),
        user: json['user'] != null
            ? RetrieveLocationSocket.fromJson(
                json['user'] as Map<String, dynamic>)
            : null,
        numAsientosRequest: json['numAsientosRequest'] == null
            ? 0
            : int.parse(json['numAsientosRequest'].toString()),
      );
    } catch (e) {
      log(e.toString());
      throw Exception("EXCEPTION SolicitudSocketModel : $e");
    }
  }
}

class RetrieveLocationSocket {
  final int id;
  final String lat;
  final String lon;
  final String rol;
  final String placa;
  final String nombreConductor;
  final String socketId;
  final int totalIncidencias;
  final int numAsientos;
  final int numAsientosActivos;

  LatLng get latLogDefault => LatLng(double.parse(lat), double.parse(lon));

  double get asientosRestantes =>
      (numAsientos - numAsientosActivos).roundToDouble();

  RetrieveLocationSocket({
    required this.id,
    required this.lat,
    required this.lon,
    required this.rol,
    required this.nombreConductor,
    this.placa = '',
    this.socketId = '',
    this.totalIncidencias = 0,
    this.numAsientos = 0,
    this.numAsientosActivos = 0,
  });

  factory RetrieveLocationSocket.fromJson(Map<String, dynamic> json) {
    try {
      return RetrieveLocationSocket(
        id: int.parse(json['id'].toString()),
        lat: json['lat'].toString(),
        lon: json['log'].toString(),
        rol: json['rol'].toString(),
        socketId: json['socketId'].toString(),
        totalIncidencias: int.parse(json['totalIncidencias'].toString()),
        numAsientos: int.parse(json['numAsientos'].toString()),
        numAsientosActivos: int.parse(json['numAsientosActivos'].toString()),
        placa: json['placa'].toString(),
        nombreConductor: json['nombreConductor'].toString(),
      );
    } catch (e) {
      log(e.toString());
      throw Exception("Error al convertir el modelo");
    }
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rol': rol,
      'lat': lat,
      'log': lon,
      'nombreConductor': nombreConductor,
      'totalIncidencias': totalIncidencias,
      'numAsientos': numAsientos,
      'numAsientosActivos': numAsientosActivos,
      'placa': placa,
    };
  }

  Map<String, dynamic> toUpdateData() {
    return {
      'lat': lat,
      'lng': lon,
      'dni': id,
      'totalIncidencias': totalIncidencias,
      'numAsientos': numAsientos,
      'numAsientosActivos': numAsientosActivos,
      'placa': placa,
    };
  }
}

final personLocationStreamProvider =
    StreamProvider<List<RetrieveLocationSocket>>((ref) async* {
  yield [];
});

final personLocationListProvider =
    StateProvider<List<RetrieveLocationSocket>>((ref) {
  return [];
});

final vehiculosActivesModulesProvider =
    StateProvider<List<RetrieveLocationSocket>>((ref) {
  return [];
});
