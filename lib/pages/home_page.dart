import 'package:app_viaje_seguro/pages/404.dart';
import 'package:app_viaje_seguro/pages/cuidador/cuidador_lista_pacientes.dart';
import 'package:app_viaje_seguro/pages/page_index/notificaciones_page.dart';
import 'package:app_viaje_seguro/pages/page_index/ubicacion_page.dart';
import 'package:app_viaje_seguro/pages/page_index/usuario_page.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/provider/google_auth.dart';
import 'package:app_viaje_seguro/provider/model_provider.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final indexomeBottomNavigatorProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // @override
  // void initState() {
  //   super.initState();
  //   // Llama a listenToSocketMessages() solo una vez al inicializar el widget.
  //   ref.read(notificationControllerProvider).listenToSocketMessages();
  // }

  Widget getWidgetByRol() {
    final tipoRolUserCredential = ref.watch(userCredentialsProvider).tipoRol;
    switch (tipoRolUserCredential) {
      case "CUIDADOR":
        return getIndexWidget(ref.watch(indexomeBottomNavigatorProvider));
      case "FAMILIAR":
        return getIndexWidget(ref.watch(indexomeBottomNavigatorProvider));
      case "PACIENTE":
        return getIndexWidgetPaciente(
            ref.watch(indexomeBottomNavigatorProvider));
      default:
        return getIndexWidget(ref.watch(indexomeBottomNavigatorProvider));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;
    final indexHome = ref.watch(indexomeBottomNavigatorProvider);
    final watch = ref.watch(getBottomMenuItemsProvider);
    final tipoRolUserCredential = ref.watch(userCredentialsProvider).tipoRol;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Bienvenido a AlzSafe"),
        actions: [
          const IconChangeTheme(),
          ShadButton(
            onPressed: () async {
              final auth = ref.read(userCredentialsProvider).tipoAuth;
              if (auth == "google") {
                final googleAuthService = GoogleAuthService(ref);
                await googleAuthService.signOut();
              }
              ref.read(userCredentialsProvider.notifier).logout();
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(builder: (context) => const SesionPage()),
                (route) => false,
              );
            },
            icon: const ShadImage.square(LucideIcons.logOut, size: 18),
          ),
        ],
      ),
      body: PopScope(
        canPop: false,
        child: SafeArea(
            child: Column(
          children: [
            Container(
              width: double.maxFinite,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.greenAccent.shade700,
              ),
              padding: const EdgeInsets.all(5),
              child: Text(
                "Eres un $tipoRolUserCredential",
                style: textTheme.h4.copyWith(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(child: getWidgetByRol()),
          ],
        )),
      ),
      bottomNavigationBar: watch.when(
        data: (menuItems) {
          return BottomNavigationBar(
              currentIndex: indexHome,
              useLegacyColorScheme: false,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              enableFeedback: true,
              selectedItemColor: Colors.deepPurpleAccent.shade200,
              onTap: (value) {
                print(value);
                ref
                    .read(indexomeBottomNavigatorProvider.notifier)
                    .update((state) => value);
              },
              items: List.generate(
                menuItems.length,
                (index) {
                  return BottomNavigationBarItem(
                    icon: Icon(menuItems[index].iconData),
                    label: menuItems[index].nombre,
                  );
                },
              ));
        },
        error: (error, stackTrace) {
          return Text("No se pudo cargar los items del menu: $error");
        },
        loading: () {
          return const ShadProgress();
        },
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

  getIndexWidgetPaciente(int index) {
    switch (index) {
      case 0:
        return const HomeIndexPageCustom();
      case 1:
        return const UsuarioIndexPage();
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

    return Center(
      child: SizedBox(
          width: 500,
          child: watch.when(
              data: (menus) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  cacheExtent: 250,
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
                  ))),
    );
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

// final List<CustomModelMenu> menuItems = [
//   CustomModelMenu(
//     iconData: LucideIcons.house,
//     nombre: 'Inicio',
//     widget: const HomeIndexPageCustom(),
//   ),
//   CustomModelMenu(
//     iconData: LucideIcons.locate,
//     nombre: 'Ubicación',
//     widget: const UbicacionIndexPage(),
//   ),
//   CustomModelMenu(
//     iconData: LucideIcons.user,
//     nombre: 'Usuario',
//     widget: const UsuarioIndexPage(),
//   ),
//   CustomModelMenu(
//     iconData: LucideIcons.bell,
//     nombre: 'Notificaciones',
//     widget: const NotificacionIndexPage(),
//   ),
// ];
