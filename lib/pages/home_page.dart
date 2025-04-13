import 'package:app_viaje_seguro/config/socket.dart';
import 'package:app_viaje_seguro/pages/404.dart';
import 'package:app_viaje_seguro/pages/cuidador/cuidador_lista_pacientes.dart';
import 'package:app_viaje_seguro/pages/home_views/cuidador_page.dart';
import 'package:app_viaje_seguro/pages/home_views/paciente_page.dart';
import 'package:app_viaje_seguro/pages/page_index/notificaciones_page.dart';
import 'package:app_viaje_seguro/pages/page_index/ubicacion_page.dart';
import 'package:app_viaje_seguro/pages/page_index/usuario_page.dart';
import 'package:app_viaje_seguro/provider/model_provider.dart';
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
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: Center(child: getIndexWidget(indexHome)),
        ),
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
          items: List.generate(
            menuItems.length,
            (index) {
              return BottomNavigationBarItem(
                icon: Icon(menuItems[index].iconData),
                label: menuItems[index].nombre,
              );
            },
          )
          // items: const [
          //   BottomNavigationBarItem(
          //     icon: Icon(LucideIcons.house),
          //     label: 'Inicio',
          //   ),
          //   BottomNavigationBarItem(
          //     icon: Icon(LucideIcons.locate),
          //     label: 'Ubicación',
          //   ),
          //   BottomNavigationBarItem(
          //     icon: Icon(LucideIcons.user),
          //     label: 'Usuario',
          //   ),
          //   BottomNavigationBarItem(
          //     icon: Icon(LucideIcons.bell),
          //     label: 'Notificaciones',
          //   ),
          // ],
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
      case 4:
        return const CuidadorPageListaPacientes();
      default:
        return const NotFound404();
    }
  }
}

class HomeIndexPageCustom extends ConsumerWidget {
  const HomeIndexPageCustom({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watch = ref.watch(getDashboardMenuItemsProvider);
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
        child: watch.when(
            data: (menus) {
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  mainAxisExtent: 250,
                ),
                itemCount: menus.length,
                itemBuilder: (context, index) {
                  final item = menus[index];
                  return ShadButton(
                    shadows: const [],
                    onPressed: () {
                      if (item.widget != null) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => item.widget!,
                          ),
                        );
                      }
                    },
                    icon: getContentButton(
                      item.nombre,
                      item.iconData,
                    ),
                  );
                },
              );
            },
            error: (error, stackTrace) => const NotFound404(),
            loading: () => const Center(
                  child: CircularProgressIndicator(),
                )));
  }
}

class CustomModelMenu {
  final IconData iconData;
  final String nombre;
  final Widget? widget;

  CustomModelMenu({
    required this.iconData,
    required this.nombre,
    this.widget,
  });
}

final List<CustomModelMenu> menuItems = [
  CustomModelMenu(
    iconData: LucideIcons.house,
    nombre: 'Inicio',
    widget: const HomeIndexPageCustom(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.locate,
    nombre: 'Ubicación',
    widget: const UbicacionIndexPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.user,
    nombre: 'Usuario',
    widget: const UsuarioIndexPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.bell,
    nombre: 'Notificaciones',
    widget: const NotificacionIndexPage(),
  ),
];
