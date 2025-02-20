import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/config/socket.dart';
import 'package:app_viaje_seguro/controller/vehiculo_controller.dart';
import 'package:app_viaje_seguro/model/home_model.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/pages/404.dart';
import 'package:app_viaje_seguro/pages/dashboard_page.dart';
import 'package:app_viaje_seguro/pages/incidencias_page.dart';
import 'package:app_viaje_seguro/pages/location_search_screen.dart';
import 'package:app_viaje_seguro/pages/page_index/notificaciones_page.dart';
import 'package:app_viaje_seguro/pages/page_index/ubicacion_page.dart';
import 'package:app_viaje_seguro/pages/page_index/usuario_page.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/pages/vehiculos_registrar.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final indexomeBottomNavigatorProvider = StateProvider<int>((ref) {
  return 0;
});

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

  @override
  Widget build(BuildContext context) {
    final indexHome = ref.watch(indexomeBottomNavigatorProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Bienvenido a AlzSafe"),
        actions: const [
          IconChangeTheme(),
        ],
      ),
      body: SafeArea(
        child: Center(child: getIndexWidget(indexHome)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indexHome,
        useLegacyColorScheme: false,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        enableFeedback: true,
        selectedItemColor: Colors.deepPurpleAccent.shade200,
        onTap: (value) => ref
            .read(indexomeBottomNavigatorProvider.notifier)
            .update((state) => value),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.house),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.locate),
            label: 'Ubicación',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Usuario',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.bell),
            label: 'Notificaciones',
          ),
        ],
      ),
    );
  }

  getIndexWidget(int index) {
    switch (index) {
      case 0:
        return const HomeIndexPageCustom();
      case 1:
        return const UbicacionIndexPage();
      case 2:
        return const UsuarioIndexPage();
      case 3:
        return const NotificacionIndexPage();
      default:
        return const NotFound404();
    }
  }
}

class HomeIndexPageCustom extends ConsumerWidget {
  const HomeIndexPageCustom({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    getContentButton(title, IconData icon) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: ShadImage.square(icon, size: 30)),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      );
    }

    return SizedBox(
      width: 500,
      child: GridView(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          mainAxisExtent: 250,
        ),
        children: [
          ShadButton.secondary(
            onPressed: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child:
                        const ShadImage.square(LucideIcons.mapPin, size: 30)),
                const Text("Ubicación"),
              ],
            ),
          ),
          ShadButton.secondary(
            onPressed: () {},
            child: getContentButton(
              "Paciente",
              LucideIcons.userPlus,
            ),
          ),
          ShadButton.secondary(
            onPressed: () {},
            child: getContentButton(
              "Cuidador",
              LucideIcons.briefcaseMedical,
            ),
          ),
          ShadButton.secondary(
            onPressed: () {},
            child: getContentButton(
              "Notificaciones",
              LucideIcons.bell,
            ),
          ),
        ],
      ),
    );
  }
}
