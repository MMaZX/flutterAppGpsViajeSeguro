import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/config/socket.dart';
import 'package:app_viaje_seguro/controller/vehiculo_controller.dart';
import 'package:app_viaje_seguro/model/home_model.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/pages/404.dart';
import 'package:app_viaje_seguro/pages/dashboard_page.dart';
import 'package:app_viaje_seguro/pages/incidencias_page.dart';
import 'package:app_viaje_seguro/pages/location_search_screen.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/pages/vehiculos_registrar.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late SocketController socket;
  @override
  void initState() {
    super.initState();
    socket = SocketController(ref: ref, context: context);
    socket.connectedSocket();
  }

  OverlayEntry? overlayEntry;

  @override
  Widget build(BuildContext context) {
    final userContent = ref.watch(getUserModelValuesProvider);

    return userContent.when(
      data: (data) {
        String rol = data.rol;
        if (rol == "CONDUCTOR") {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Viaje Seguro App",
                style: TextStyle(fontWeight: FontWeight.bold, height: 0),
              ),
              actions: const [IconChangeTheme()],
            ),
            drawer: const _DrawerContent(),
            body: const GetWidget(),
          );
        }
        if (rol == "PASAJERO") {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Viaje Seguro App",
                style: TextStyle(fontWeight: FontWeight.bold, height: 0),
              ),
              actions: const [IconChangeTheme()],
            ),
            body: const SearchLocationScreen(),
          );
        }
        return const NotFound404();
      },
      error: (error, stackTrace) {
        return Scaffold(
          body: Center(
            child: Text(error.toString()),
          ),
        );
      },
      loading: () {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class _DrawerContent extends ConsumerStatefulWidget {
  const _DrawerContent();
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __DrawerContentState();
}

class __DrawerContentState extends ConsumerState<_DrawerContent> {
  @override
  Widget build(BuildContext context) {
    int indexSelected = ref.watch(indexHomeProvider);
    final userContent = ref.watch(getUserModelValuesProvider);
    return SafeArea(
        child: Drawer(
      child: Column(
        children: [
          15.he,
          userContent.when(
            data: (data) {
              UsuarioModel item = data;
              return ListTile(
                leading: const Icon(Icons.gps_fixed_sharp),
                title: const Text("Viaje Seguro"),
                subtitle: Text(
                    "${item.nombre} ${item.apellidoPaterno} ${item.apellidoMaterno} [${item.rol}]"),
              );
            },
            error: (error, stackTrace) {
              return ListTile(
                leading: const Icon(Icons.gps_off_rounded),
                title: const Text("Estado ERROR"),
                subtitle: Text(error.toString()),
              );
            },
            loading: () {
              return const ListTile(
                leading: Icon(Icons.gps_off_rounded),
                title: Text("Viaje Seguro"),
                subtitle: Text("..."),
              );
            },
          ),
          const Divider(),
          10.he,
          // const ListTile(title: Text("Acciones")),
          Expanded(
              child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: indexList().length,
            itemBuilder: (context, index) {
              final item = indexList()[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MaterialButton(
                  color: indexSelected == item.index
                      ? Colors.blueAccent.shade700
                      : Colors.grey.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  onPressed: () {
                    ref
                        .read(indexHomeProvider.notifier)
                        .update((state) => item.index);
                    isBackReturn(context);
                  },
                  elevation: 0,
                  focusElevation: 0,
                  hoverElevation: 0,
                  disabledElevation: 0,
                  highlightElevation: 0,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Opacity(
                        opacity: indexSelected == item.index ? 1 : 0.5,
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            height: 0,
                            fontWeight: FontWeight.bold,
                            color: indexSelected == item.index
                                ? Colors.white
                                : null,
                          ),
                        )),
                  ),
                ),
              );
            },
          )),
// logout
          ButtonCustomBase(
            color: Colors.redAccent.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            onPressed: () async {
              await SharedToken().deleteLoginToken();
              ref.invalidate(getUserModelValuesProvider);
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const SesionPage(),
                  ),
                  (route) => false);
            },
            title: "Cerrar sesión",
          )
        ],
      ),
    ));
  }
}

class GetWidget extends ConsumerWidget {
  const GetWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indexSelected = ref.watch(indexHomeProvider);
    return PopScope(
      canPop: false,
      child: _buildContent(indexSelected),
    );
  }
}

Widget _buildContent(indexSelected) {
  switch (indexSelected) {
    case 1:
      return const DashboardPage();
    case 2:
      return const IncidenciasPage();
    case 3:
      return const SearchLocationScreen();
    case 4:
      return const VehiculosPage();
    default:
      return const NotFound404();
  }
}
