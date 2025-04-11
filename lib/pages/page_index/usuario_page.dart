import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/usuario_model.dart';
import 'package:app_viaje_seguro/pages/registrar_page.dart';
import 'package:app_viaje_seguro/pages/widgets_constants.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
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


  UsuarioAccessModel model = UsuarioAccessModel();
  @override
  Widget build(BuildContext context) {
    final controller = UsuariosController(context, ref);

    return FutureCustomWidget(
        future: controller.getUsersById(),
        widgetBuilder: (context, snapshot) {
          UsuarioAccessModel usuario = snapshot.data;
          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              const ShadAlert(
                title: Text("Perfil del usuario"),
                description: Opacity(
                  opacity: 0.6,
                  child: Text("Puede editar la información de tu sesión."),
                ),
              ),

              const SizedBox(height: 10),

              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Nombre"),
                initialValue: usuario.name, onChanged: (p0) => usuario.name = p0,
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: Text("Usuario"),
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

              ShadButton(
                onPressed: () {},
                child: const Text("Editar información de usuario"),
              ),
            ],
          );
        });
  }
}
