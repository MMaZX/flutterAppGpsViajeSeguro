import 'package:app_viaje_seguro/pages/registrar_page.dart';
import 'package:app_viaje_seguro/pages/widgets_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UsuarioIndexPage extends ConsumerStatefulWidget {
  const UsuarioIndexPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UsuarioIndexPageState();
}

class _UsuarioIndexPageState extends ConsumerState<UsuarioIndexPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      children: [
        const ShadAlert(
          title: Text("Perfil del usuario"),
          description: Opacity(
            opacity: 0.6,
            child: Text("Puede editar la información de tu sesión."),
          ),
        ),
        ShadButton(
          onPressed: () {},
          child: const Text("Editar información de usuario"),
        ),
        ShadInputFormField(
          decoration: inputDecoration,
          label: Text("Nombre"),
        ),
        ShadInputFormField(
          decoration: inputDecoration,
          label: Text("usuario"),
        ),
        ShadInputFormField(
          decoration: inputDecoration,
          label: Text("Contraseña"),
        ),
        ShadInputFormField(
          decoration: inputDecoration,
          label: Text("Telefono"),
        ),
        ShadInputFormField(
          decoration: inputDecoration,
          label: Text("Dirección"),
        ),
        // ShadInputFormField(
        //   decoration: inputDecoration,
        //   label: Text("rol"),
        // ),
        SelectedRolUsuario(
          onChanged: (value) {},
        ),
      ],
    );
  }
}
