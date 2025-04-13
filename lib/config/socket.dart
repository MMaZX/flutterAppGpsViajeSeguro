// import 'dart:async';
// import 'dart:developer';
// import 'package:app_viaje_seguro/config/api.dart';
// import 'package:app_viaje_seguro/config/shared_preferences.dart';
// import 'package:app_viaje_seguro/controller/controller_state.dart';
// import 'package:app_viaje_seguro/controller/incidencias_controller.dart';
// import 'package:app_viaje_seguro/controller/vehiculo_controller.dart';
// import 'package:app_viaje_seguro/model/prediction.dart';
// import 'package:app_viaje_seguro/model/request_model.dart';
// import 'package:app_viaje_seguro/model/usuarios_model.dart';
// import 'package:app_viaje_seguro/model/vehiculo_model.dart';
// import 'package:app_viaje_seguro/pages/conductor_page.dart';
// import 'package:app_viaje_seguro/pages/esperando_page.dart';
// import 'package:app_viaje_seguro/provider/geolocator_provider.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// // import 'package:socket_io_client/socket_io_client.dart' as io;
// import 'package:socket_io_client/socket_io_client.dart';

// class SocketController {
//   final WidgetRef ref;
//   final BuildContext context;
//   SocketController({required this.ref, required this.context});

//   // any getters

//   static String socketurl = "http://192.168.1.22:3000";

//   // String socketurl = "http://rutaapiportmap.portmap.io:37161";
//   Socket socket = io(socketurl, <String, dynamic>{
//     'transports': ['websocket'],
//     'autoConnect': true,
//   });

//   // Inicializamos la lista de ese Stream
//   List<RetrieveLocationSocket> userConnectedList = [];

//   // INICIALIZAMOS EL STREAM
//   final StreamController<List<RetrieveLocationSocket>> _controller =
//       StreamController<List<RetrieveLocationSocket>>.broadcast();

//   void connectedSocket() {
//     socket.connect();
//     socket.onConnect((_) {
//       print('Connected and WS!!');

//     });

//     // DESCONECTAR EL SOCKET BB
//     socket.onDisconnect((_) {
//       print("Disconnected from WebSocket server");
//     });
//   }

//   Future<void> sendSolicitud(int dni, int numAsientos) async {
   
//     socket.emit('sendSolicitud', {
//       'dni': dni,
//       'numAsientos': numAsientos,
//       'dnipasajero': ''
//     });
//   }

//   Stream<List<RetrieveLocationSocket>> getAllUsersConductores() {
//     List<RetrieveLocationSocket> userConnectedList = [];
//     socket.on("allUsersConnected", (data) {
//       try {
//         if (data is List<dynamic>) {
//           userConnectedList.clear();
//           for (var item in data) {
//             if (item is Map<String, dynamic>) {
//               if (item['rol'] == 'PASAJERO') continue; // Saltar los pasajeros
//               userConnectedList.add(RetrieveLocationSocket.fromJson(item));
//             }
//           }
//           _controller.add(userConnectedList);
//         }
//       } catch (e) {
//         log("ERROR ALLUSERCONNECTED: $e");
//         _controller.addError(e);
//       }
//     });
//     return _controller.stream;
//   }
// }

// class _SocketFunctions {
//   final Socket socket;
//   final BuildContext context;

//   _SocketFunctions(
//     this.socket,
//     this.context,
//   );

// }

// class SocketRequest {
//   final BuildContext context;
//   SocketRequest(this.context);

//   Dio dio = Dio();

//   Future<VehiculoModel>? getDataVehiculo(int dni) async {
//     final path = Endpoint(context: context)
//         .getPathById(ContentApi.vehiculosPorDNI, dni.toString());
//     try {
//       final response = await dio.get(path);
//       final json = response.data;
//       final model = VehiculoModel.fromGetDataJson(json);
//       return model;
//     } on DioException catch (e) {
//       Map<String, dynamic> json = e.response?.data ?? {};
//       showSnackbarCustom(context, json.toString());
//       throw Exception("Error al obtener los datos del vehículo");
//     }
//   }
// }

// class SolicitudSocketModel {
//   final bool value;
//   final String message;
//   final int dni;
//   final int dniPasajero;
//   final int? numAsientosRequest;
//   final RetrieveLocationSocket? user;

//   SolicitudSocketModel.isEmpty()
//       : value = false,
//         message = '',
//         dni = 0,
//         user = null,
//         dniPasajero = 0,
//         numAsientosRequest = 0;

//   SolicitudSocketModel({
//     required this.value,
//     required this.message,
//     required this.user,
//     required this.numAsientosRequest,
//     required this.dniPasajero,
//     required this.dni,
//   });
//   factory SolicitudSocketModel.fromJson(Map<String, dynamic> json) {
//     try {
//       return SolicitudSocketModel(
//         value: bool.parse(json['value'].toString()),
//         message: json['message'].toString(),
//         dni: int.parse(json['dni'].toString()),
//         dniPasajero: int.parse(json['dnipasajero'].toString()),
//         user: json['user'] != null
//             ? RetrieveLocationSocket.fromJson(
//                 json['user'] as Map<String, dynamic>)
//             : null,
//         numAsientosRequest: json['numAsientosRequest'] == null
//             ? 0
//             : int.parse(json['numAsientosRequest'].toString()),
//       );
//     } catch (e) {
//       log(e.toString());
//       throw Exception("EXCEPTION SolicitudSocketModel : $e");
//     }
//   }
// }

// class RetrieveLocationSocket {
//   final int id;
//   final String lat;
//   final String lon;
//   final String rol;
//   final String placa;
//   final String nombreConductor;
//   final String socketId;
//   final int totalIncidencias;
//   final int numAsientos;
//   final int numAsientosActivos;

//   LatLng get latLogDefault => LatLng(double.parse(lat), double.parse(lon));

//   double get asientosRestantes =>
//       (numAsientos - numAsientosActivos).roundToDouble();

//   RetrieveLocationSocket({
//     required this.id,
//     required this.lat,
//     required this.lon,
//     required this.rol,
//     required this.nombreConductor,
//     this.placa = '',
//     this.socketId = '',
//     this.totalIncidencias = 0,
//     this.numAsientos = 0,
//     this.numAsientosActivos = 0,
//   });

//   factory RetrieveLocationSocket.fromJson(Map<String, dynamic> json) {
//     try {
//       return RetrieveLocationSocket(
//         id: int.parse(json['id'].toString()),
//         lat: json['lat'].toString(),
//         lon: json['log'].toString(),
//         rol: json['rol'].toString(),
//         socketId: json['socketId'].toString(),
//         totalIncidencias: int.parse(json['totalIncidencias'].toString()),
//         numAsientos: int.parse(json['numAsientos'].toString()),
//         numAsientosActivos: int.parse(json['numAsientosActivos'].toString()),
//         placa: json['placa'].toString(),
//         nombreConductor: json['nombreConductor'].toString(),
//       );
//     } catch (e) {
//       log(e.toString());
//       throw Exception("Error al convertir el modelo");
//     }
//   }
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'rol': rol,
//       'lat': lat,
//       'log': lon,
//       'nombreConductor': nombreConductor,
//       'totalIncidencias': totalIncidencias,
//       'numAsientos': numAsientos,
//       'numAsientosActivos': numAsientosActivos,
//       'placa': placa,
//     };
//   }

//   Map<String, dynamic> toUpdateData() {
//     return {
//       'lat': lat,
//       'lng': lon,
//       'dni': id,
//       'totalIncidencias': totalIncidencias,
//       'numAsientos': numAsientos,
//       'numAsientosActivos': numAsientosActivos,
//       'placa': placa,
//     };
//   }
// }

// final personLocationStreamProvider =
//     StreamProvider<List<RetrieveLocationSocket>>((ref) async* {
//   yield [];
// });

// final personLocationListProvider =
//     StateProvider<List<RetrieveLocationSocket>>((ref) {
//   return [];
// });

// final vehiculosActivesModulesProvider =
//     StateProvider<List<RetrieveLocationSocket>>((ref) {
//   return [];
// });
