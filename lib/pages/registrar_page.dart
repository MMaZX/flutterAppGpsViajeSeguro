import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/provider/model_provider.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// My packages
import 'package:app_viaje_seguro/widgets/widgets.dart';

class RegistrarPage extends ConsumerStatefulWidget {
  const RegistrarPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegistrarPageState();
}

class _RegistrarPageState extends ConsumerState<RegistrarPage> {
  TextEditingController nombresController = TextEditingController();
  TextEditingController apellidosPaternoController = TextEditingController();
  TextEditingController apellidoMaternoController = TextEditingController();
  TextEditingController dniController = TextEditingController();
  TextEditingController numerodecelularController = TextEditingController();
  TextEditingController usuarioController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
// TextEditingController Controller = TextEditingController();
// TextEditingController Controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final rolSelected = ref.watch(selectedRolDropdownProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registrate",
          style: TextStyle(fontWeight: FontWeight.w900, height: 0),
        ),
        actions: const [
          IconChangeTheme(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                const Text("Selecciona tu rol"),
                const RolDropdownCustom(),
                15.he,
                const Text(
                  "Ingresa tus datos personales para continuar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                10.he,
                const Text("Nombre"),
                TextFormCustom(
                  controller: nombresController,
                ),
                const Text("Apellido Paterno"),
                TextFormCustom(
                  controller: apellidosPaternoController,
                ),
                const Text("Apellido Materno"),
                TextFormCustom(
                  controller: apellidoMaternoController,
                ),
                const Text("DNI"),
                TextFormCustom(
                  controller: dniController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
                const Text("Número de celular"),
                TextFormCustom(
                  controller: numerodecelularController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                ),
                //
                10.he,
                const Divider(),
                10.he,
                const Text(
                  "Genera tus credenciales",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text("Usuario"),
                TextFormCustom(
                  controller: usuarioController,
                ),
                const Text("Clave de Acceso"),
                TextFormCustom(
                  controller: passwordController,
                ),
                20.he,
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: MaterialButton(
              minWidth: double.maxFinite,
              color: colorsThemeDefault(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              onPressed: () async {
                final usuario = UsuarioModel(
                    nombre: nombresController.text,
                    apellidoPaterno: apellidosPaternoController.text,
                    apellidoMaterno: apellidoMaternoController.text,
                    dni: dniController.text,
                    celular: numerodecelularController.text,
                    usuario: usuarioController.text,
                    clave: passwordController.text,
                    rol: rolSelected,
                    );
                DialogFState(context).showLoading();

                final value =
                    await UsuariosController(context: context, ref: ref)
                        .createUser(usuario);
                isBackReturn(context);
                ref.invalidate(getUserModelValuesProvider);
                DialogFState(context).showContentDialog(
                  CupertinoAlertDialog(
                    title: Text(value.statusCode == 200 ? "Correcto" : "Error"),
                    content: Text(value.message),
                    actions: [
                      CupertinoDialogAction(
                        onPressed: () => isBackReturn(context),
                        child: const Text("Aceptar"),
                      )
                    ],
                  ),
                );

                if (value.statusCode == 200) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(
                      builder: (context) {
                        return const HomePage();
                      },
                    ),
                    (route) => false,
                  );
                }

              },
              child: Container(
                  padding: const EdgeInsets.all(15),
                  child: const Text(
                    "Registrar usuario",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )),
            ),
          ),
          10.he,
        ],
      ),
    );
  }
}

class DialogFState {
  final BuildContext context;

  DialogFState(this.context);

  Future<void> showContentDialog(Widget widgetDialog) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
            canPop: false,
            // ignore: deprecated_member_use
            onPopInvoked: (didPop) async {
              return;
            },
            child: widgetDialog);
      },
    );
  }

  Future<void> showLoading() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
            canPop: false,
            // ignore: deprecated_member_use
            onPopInvoked: (didPop) async {
              return;
            },
            child: const Center(
              child: CircularProgressIndicator(),
            ));
      },
    );
  }
}

class DialogStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final bool isSuccess;
  const DialogStateWidget(
      {super.key,
      required this.title,
      required this.message,
      this.isSuccess = false});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CupertinoButton(
          color: isSuccess ? Colors.blueAccent.shade700 : Colors.redAccent,
          onPressed: () => isBackReturn(context),
          child: const Text("Aceptar"),
        )
      ],
    );
  }
}
