// import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
// import 'package:app_viaje_seguro/controller/vehiculo_controller.dart';
// import 'package:app_viaje_seguro/model/response_model.dart';
// import 'package:app_viaje_seguro/model/usuarios_model.dart';
// import 'package:app_viaje_seguro/model/vehiculo_model.dart';
// import 'package:app_viaje_seguro/pages/registrar_page.dart';
// import 'package:app_viaje_seguro/widgets/model_widgets.dart';
// import 'package:app_viaje_seguro/widgets/widgets.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class VehiculosPage extends ConsumerStatefulWidget {
//   const VehiculosPage({super.key});
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _VehiculosPageState();
// }

// class _VehiculosPageState extends ConsumerState<VehiculosPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 15),
//       child: Column(
//         children: [
//           const ListTile(
//             contentPadding: EdgeInsets.zero,
//             title: Text("Lista de vehiculos",
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             subtitle: Text("Información de los vehíuclos registrados"),
//           ),
//           Expanded(
//             child: FutureCustomWidget(
//               future:
//                   VehiculoController(context: context, ref: ref).getVehiculos(),
//               widgetBuilder: (context, snapshot) {
//                 List<VehiculoModel> item = snapshot.data;

//                 if (item.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       "No existen datos\n¡¡Crea algunos vehículos!!",
//                       textAlign: TextAlign.center,
//                     ),
//                   );
//                 }

//                 return RefreshIndicator(
//                   onRefresh: () async {
//                     setState(() {});
//                   },
//                   child: ListView.builder(
//                     itemCount: item.length,
//                     itemBuilder: (context, index) {
//                       final data = item[index];
//                       return ListTile(
//                         leading: const Icon(Icons.car_crash_outlined),
//                         title: Text(data.placa.toString()),
//                         subtitle: Text(data.nombreConductor.toString()),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//           //
//           MaterialButton(
//             onPressed: () async {
   
//             },
//             minWidth: double.maxFinite,
//             color: Theme.of(context).colorScheme.primary,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: const Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Text("Registrar vehículos")),
//           ),
//           10.he,
//         ],
//       ),
//     );
//   }
// }

// class DialogRegistrarVehiculos extends ConsumerStatefulWidget {
//   const DialogRegistrarVehiculos({super.key});
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _DialogRegistrarVehiculosState();
// }

// class _DialogRegistrarVehiculosState
//     extends ConsumerState<DialogRegistrarVehiculos> {
//   TextEditingController placaController = TextEditingController();
//   TextEditingController dniController = TextEditingController();
//   TextEditingController nombreController = TextEditingController();

//   bool isVehiculo = false;

//   int value = 1;
//   @override
//   Widget build(BuildContext context) {
//     final query = MediaQuery.sizeOf(context);
//     return SizedBox(
//       height: query.height * 0.55,
//       child: ListView(
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         children: [
//           const ListTile(
//             contentPadding: EdgeInsets.zero,
//             title: Text(
//               "Registrar vehiculo",
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           TextFormCustom(
//               hintText: "Numero de placa", controller: placaController),
//           10.he,
//           const BuscarUsuarioPasajero(),
//           10.he,
//           ListTile(
//             title: Text(
//               "Cantidad de asientos: $value",
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Slider(
//               value: value.toDouble(),
//               min: 1,
//               max: 18,
//               label: value.round().toString(),
//               allowedInteraction: SliderInteraction.tapAndSlide,
//               onChanged: (cant) {
//                 setState(() {
//                   value = cant.round();
//                 });
//               },
//             ),
//           ),
//           MaterialButton(
//             onPressed: () async {
//               isBackReturn(context);
//             },
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//             color: Colors.grey,
//             child: Container(
//                 padding: const EdgeInsets.all(10),
//                 child: const Text("Volver",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ))),
//           ),
//           5.he,
//           isVehiculo
//               ? const Center(child: CircularProgressIndicator())
//               : MaterialButton(
//                   onPressed: () async {
//                     final usuarioSelectedVehiculo =
//                         ref.watch(usuarioSelectedVehiculoProvider);
//                     setState(() {
//                       isVehiculo = true;
//                     });
//                     final model = VehiculoModel(
//                       placa: placaController.text,
//                       numAsientos: value,
//                       dni: usuarioSelectedVehiculo,
//                     );
//                     ResponseModel response =
//                         await VehiculoController(context: context, ref: ref)
//                             .createVehiculo(model);
//                     setState(() {
//                       isVehiculo = false;
//                     });

//                     if (response.statusCode == 200) {
//                       isBackReturn(context);
//                     } else {
                   
//                     }
//                   },
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15)),
//                   color: Theme.of(context).colorScheme.primary,
//                   child: Container(
//                       padding: const EdgeInsets.all(10),
//                       child: const Text("Registrar vehiculo",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ))),
//                 )
//         ],
//       ),
//     );
//   }
// }

// class BuscarUsuarioPasajero extends ConsumerStatefulWidget {
//   const BuscarUsuarioPasajero({super.key});
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _BuscarUsuarioPasajeroState();
// }

// class _BuscarUsuarioPasajeroState extends ConsumerState<BuscarUsuarioPasajero> {
//   final BorderRadius _radius = BorderRadius.circular(15);
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

// final usuarioSelectedVehiculoProvider = StateProvider<String>((ref) {
//   return "";
// });
