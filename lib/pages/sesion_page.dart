import 'dart:developer';

import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/controller/incidencias_controller.dart';
import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/prediction.dart';
import 'package:app_viaje_seguro/model/response_model.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/pages/registrar_page.dart';
import 'package:app_viaje_seguro/provider/theme_cubit.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SesionPage extends ConsumerStatefulWidget {
  const SesionPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SesionPageState();
}

class _SesionPageState extends ConsumerState<SesionPage> {
  @override
  Widget build(BuildContext context) {
    final modelToken = ref.watch(getUserModelValuesProvider);
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              // backgroundColor: Colors.transparent,
              actions: const [
                IconChangeTheme(),
              ],
            ),
            body: Column(
              children: [
                10.he,
                const Text(
                  "VIAJE\n SEGURO",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 0,
                    fontSize: 20,
                  ),
                ),
                20.he,
                modelToken.when(
                  data: (data) {
                    UsuarioModel item = data;

                    if (item.dni.isEmpty) {
                      return const FormLoginBasePage();
                    }

                    return MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      onPressed: () async =>
                          _loginSession(item.usuario, item.clave, context, ref),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 5),
                        title: Text(
                          "${item.nombre} ${item.apellidoPaterno} ${item.apellidoMaterno}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Opacity(
                          opacity: 0.7,
                          child: Text(
                            item.rol,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text("Advertencia"),
                                    content: const Text(
                                        "¿Estás seguro de eliminar esta sesión? Volverás a iniciar sesión."),
                                    actions: [
                                      CupertinoDialogAction(
                                        onPressed: () => isBackReturn(context),
                                        child: const Text("Volver"),
                                      ),
                                      CupertinoDialogAction(
                                        onPressed: () => deleteSession(),
                                        child: const Text("Eliminar"),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.close)),
                      ),
                    );
                  },
                  error: (error, stackTrace) {
                    return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: ListTile(
                          title: const Text(
                              "Ha ocurrido un error al momento de obtener los datos de sesión."),
                          trailing: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: const Text("Advertencia"),
                                      content: const Text(
                                          "¿Estás seguro de eliminar esta sesión? Volverás a iniciar sesión."),
                                      actions: [
                                        CupertinoDialogAction(
                                          onPressed: () =>
                                              isBackReturn(context),
                                          child: const Text("Volver"),
                                        ),
                                        CupertinoDialogAction(
                                          onPressed: () => deleteSession(),
                                          child: const Text("Eliminar"),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.close)),
                        ));
                  },
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                ),
                10.he,
                ButtonCustomBase(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  color: Colors.blueAccent.shade100,
                  colorText: Colors.black,
                  onPressed: () {
                    Navigator.push(context, CupertinoPageRoute(
                      builder: (context) {
                        return const RegistrarPage();
                      },
                    ));
                  },
                  title: "Registrarte",
                ),
                10.he,
              ],
            ));
      },
    );
  }

  Future<void> deleteSession() async {
    // DialogFState(context).showLoading();
    await SharedToken().deleteLoginToken();
    isBackReturn(context);
    ref.invalidate(getUserModelValuesProvider);
  }
}

Future<void> _loginSession(
    String usuario, String clave, context, WidgetRef ref) async {
  try {
    DialogFState(context).showLoading();
    ResponseModel value = await UsuariosController(context: context, ref: ref)
        .loginSessionUser(usuario: usuario, clave: clave);
    isBackReturn(context);
    ref.invalidate(getUserModelValuesProvider);
    if (value.statusCode != 200) {
      throw Exception(value.message.toString());
    }
    getStatusActive(context);
  } catch (e) {
    log(e.toString());
    showSnackbarCustom(context, e.toString());
  }
}

final getUserModelValuesProvider = FutureProvider<UsuarioModel>((ref) async {
  return SharedToken().getLoginToken();
});

class FormLoginBasePage extends ConsumerStatefulWidget {
  const FormLoginBasePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FormLoginBasePageState();
}

class _FormLoginBasePageState extends ConsumerState<FormLoginBasePage> {
  Color valueColor(bool state) {
    return state ? Colors.white : Colors.black;
  }

  TextEditingController usuarioController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool mostrarPassword = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              10.he,
              TextFormCustom(
                hintText: "Usuario",
                backgroundColor: Colors.transparent,
                color: valueColor(state),
                controller: usuarioController,
              ),
              10.he,
              TextFormCustom(
                hintText: "Clave",
                backgroundColor: Colors.transparent,
                color: valueColor(state),
                obscureText: !mostrarPassword,
                controller: passwordController,
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                value: mostrarPassword,
                onChanged: (value) {
                  setState(() {
                    mostrarPassword = value!;
                  });
                },
                title: const Text("Mostrar contraseña"),
              ),
              15.he,
              ButtonCustomBase(
                  color: valueColor(state),
                  colorText: valueColor(!state),
                  padding: const EdgeInsets.only(bottom: 5),
                  onPressed: () {},
                  title: "¿Olvidaste tus datos?"),
              ButtonCustomBase(
                  color: Colors.grey.withOpacity(0.2),
                  colorText: valueColor(state),
                  padding: const EdgeInsets.only(bottom: 5),
                  onPressed: () async => _loginSession(usuarioController.text,
                      passwordController.text, context, ref),
                  title: "Ingresar"),
            ],
          ),
        );
      },
    );
  }
}
