import 'package:app_viaje_seguro/config/socket.dart';
import 'package:app_viaje_seguro/controller/cloud_controller.dart';
import 'package:app_viaje_seguro/controller/controller_state.dart';
import 'package:app_viaje_seguro/controller/vehiculo_controller.dart';
import 'package:app_viaje_seguro/model/vehiculo_model.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/pages/maps.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class EsperandoPage extends ConsumerStatefulWidget {
  final int dniPasajero;
  final int dniConductor;
  final int numAsientos;
  const EsperandoPage(
      {super.key,
      required this.dniPasajero,
      required this.dniConductor,
      required this.numAsientos});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EsperandoPageState();
}

class _EsperandoPageState extends ConsumerState<EsperandoPage> {
  late SocketController socketController;

  void initState() {
    super.initState();
    socketController = SocketController(ref: ref, context: context);
    // Simulación de escucha de eventos del socket
    socketController.socket.on('esperandoPasajero', (data) {
      if (!mounted) return;

      ref.invalidate(solicitudPasajeroProvider);
      if (data is Map<String, dynamic>) {
        final int estado = data['estado'];
        // Actualizar el estado basado en el valor recibido
        SolicitudEstadoPasajero nuevoEstado;
        switch (estado) {
          case 0:
            nuevoEstado = SolicitudEstadoPasajero.waiting;
            break;
          case 1:
            nuevoEstado = SolicitudEstadoPasajero.accepted;
            break;
          case 2:
            nuevoEstado = SolicitudEstadoPasajero.rejected;
            break;
          default:
            throw Exception("Estado de solicitud no reconocido: $estado");
        }
        actualizarEstadoSolicitud(nuevoEstado);
      }
    });
  }

  @override
  void dispose() {
    // Limpiar la suscripción del socket
    socketController.socket.off('esperandoPasajero');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Esperando",
            style: TextStyle(fontWeight: FontWeight.bold, height: 0),
          ),
          actions: const [IconChangeTheme()],
        ),
        //
        body: PopScope(
            canPop: true,
            child: Container(
              child: _builderWidget(ref),
            )),
      ),
    );
  }

  Widget _builderWidget(WidgetRef ref) {
    final solicitudPasajero = ref.watch(solicitudPasajeroProvider);

    if (solicitudPasajero == SolicitudEstadoPasajero.waiting) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              child: const Text(
                "Esperando respuesta del conductor",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const CircularProgressIndicator(),
          ],
        ),
      );
    }
    if (solicitudPasajero == SolicitudEstadoPasajero.accepted) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Solicitud Aceptada"),
            ButtonCustomBase(
              onPressed: () async {
                try {
                  final retrieveModel = ref.watch(retrieveMapSearchBoxProvider);
                  Position position = await Geolocator.getCurrentPosition();
                  final model = ReporteViajeModel(
                    dniUsuario: widget.dniPasajero.toString(),
                    dniConductor: widget.dniConductor.toString(),
                    numAsientos: widget.numAsientos,
                    lngInicial: position.longitude,
                    latInicial: position.longitude,
                    lngFinal: retrieveModel.properties.coordinates.longitude,
                    latFinal: retrieveModel.properties.coordinates.latitude,
                    direccionFinal: retrieveModel.properties.fullAddress,
                    estado: 0,
                  );
                  await VehiculoController(context: context)
                      .crearReporteViaje(model);
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(
                      builder: (context) {
                        return MapFlutterWidget(
                          dniConductor: widget.dniConductor,
                        );
                      },
                    ),
                    (route) => false,
                  );
                } catch (e) {
                  print(e);
                }
              },
              padding: const EdgeInsets.symmetric(horizontal: 30),
              title: "Continuar",
            ),
            20.he,
          ],
        ),
      );
    }
    if (solicitudPasajero == SolicitudEstadoPasajero.rejected) {
      return  Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            MaterialButton(onPressed: () {
               Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                  (route) => false,
                );
            },
            child: 
            const Text("Volver"),
            ),
          ],
        ),
      );

    }
    return const Center(child: Text("HA OCURRIDO UN ERROR INESPERADO"));
  }

  // Método para actualizar el estado de la solicitud
  void actualizarEstadoSolicitud(SolicitudEstadoPasajero nuevoEstado) {
    ref
        .read(solicitudPasajeroProvider.notifier)
        .update((estado) => nuevoEstado);
  }
}

class _RechazadoPage extends StatefulWidget {
  const _RechazadoPage({
    super.key,
  });

  @override
  State<_RechazadoPage> createState() => _RechazadoPageState();
}

class _RechazadoPageState extends State<_RechazadoPage> {

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Solicitud Rechazada"));
  }
}

final solicitudPasajeroProvider = StateProvider<SolicitudEstadoPasajero>((ref) {
  return SolicitudEstadoPasajero.waiting;
});
