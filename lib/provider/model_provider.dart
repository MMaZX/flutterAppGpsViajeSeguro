import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/pages/cuidador/cuidador_lista_pacientes.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/pages/home_views/cuidador_page.dart';
import 'package:app_viaje_seguro/pages/home_views/familiar/familiar_page.dart';
import 'package:app_viaje_seguro/pages/home_views/paciente_page.dart';
import 'package:app_viaje_seguro/pages/page_index/notificaciones_page.dart';
import 'package:app_viaje_seguro/pages/page_index/ubicacion_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final getDashboardMenuItemsProvider =
    FutureProvider.autoDispose<List<CustomModelMenu>>((ref) async {
  String watch = await AuthPrefs().getTipoRol();
  print("getDashboardMenuItemsProvider: $watch");
  String rol = watch.trim().toLowerCase();
  if (rol == RolUsuario.admin.name) {
    return menuHomeItemsAdmin;
  } else if (rol == RolUsuario.cuidador.name) {
    return menuHomeItemsCuidador;
  } else if (rol == RolUsuario.familiar.name) {
    return menuHomeItemsFamiliar;
  } else if (rol == RolUsuario.paciente.name) {
    return menuHomeItemsPacientes;
  }
  // Si no coincide con ninguno de los roles, puedes manejarlo como desees

  return [];
});

enum RolUsuario {
  paciente,
  cuidador,
  familiar,
  admin,
}

final List<CustomModelMenu> menuHomeItemsAdmin = [
  CustomModelMenu(
    iconData: LucideIcons.mapPin,
    nombre: 'Ubicación',
    widget: const UbicacionIndexPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.userPlus,
    nombre: 'Paciente',
    widget: const PacientePage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.briefcaseMedical,
    nombre: 'Cuidador',
    widget: const CuidadorPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.bell,
    nombre: 'Notificaciones',
    widget: const NotificacionIndexPage(),
  ),
];

final List<CustomModelMenu> menuHomeItemsPacientes = [
  CustomModelMenu(
    iconData: LucideIcons.mapPin,
    nombre: 'Ubicación',
    widget: const UbicacionIndexPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.usersRound,
    nombre: 'Familiar',
    widget: const FamiliarPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.briefcaseMedical,
    nombre: 'Cuidador',
    widget: const CuidadorPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.bell,
    nombre: 'Notificaciones',
    widget: const NotificacionIndexPage(),
  ),
];

final List<CustomModelMenu> menuHomeItemsCuidador = [
  CustomModelMenu(
    iconData: LucideIcons.mapPin,
    nombre: 'Ubicación',
    widget: const UbicacionIndexPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.userPlus,
    nombre: 'Tus pacientes',
    widget: const CuidadorPageListaPacientes(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.usersRound,
    nombre: 'Familiar',
    widget: const FamiliarPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.bell,
    nombre: 'Notificaciones',
    widget: const NotificacionIndexPage(),
  ),
];

final List<CustomModelMenu> menuHomeItemsFamiliar = [
  CustomModelMenu(
    iconData: LucideIcons.mapPin,
    nombre: 'Ubicación',
    widget: const UbicacionIndexPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.userPlus,
    nombre: 'Paciente',
    widget: const PacientePage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.briefcaseMedical,
    nombre: 'Cuidador',
    widget: const CuidadorPage(),
  ),
  CustomModelMenu(
    iconData: LucideIcons.bell,
    nombre: 'Notificaciones',
    widget: const NotificacionIndexPage(),
  ),
];
