import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/pages/home_views/paciente_create.dart';
import 'package:app_viaje_seguro/pages/page_index/usuario_page.dart';
import 'package:app_viaje_seguro/pages/registrar_page.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/pages/widgets_constants.dart';
import 'package:app_viaje_seguro/provider/google_auth.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:app_viaje_seguro/services/background_services.dart';
import 'package:app_viaje_seguro/services/ws_connection_provider.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FormularioSesionGooglePage extends ConsumerStatefulWidget {
  final GoogleSignInAccount account;

  const FormularioSesionGooglePage({required this.account, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FormularioSesionGooglePageState();
}

class _FormularioSesionGooglePageState
    extends ConsumerState<FormularioSesionGooglePage> {
  String user = '';
  String password = '';
  String rol = ''; // Valor predeterminado
  String country = ''; // Valor predeterminado
  String address = '';
  int age = 0;
  String genre = ''; // Valor predeterminado
  String phone = '';
  String identification = '';

  Future<void> _sendUserDataToBackend({
    required String user,
    required String password,
    required String rol,
    required String country,
    required String address,
    required int age,
    required String genre,
    required String phone,
    required String identification,
  }) async {
    try {
      if (user.isEmpty ||
          password.isEmpty ||
          rol.isEmpty ||
          country.isEmpty ||
          address.isEmpty ||
          age <= 0 ||
          genre.isEmpty ||
          phone.isEmpty ||
          identification.isEmpty) {
        throw Exception(
            'Todos los campos son obligatorios y deben ser válidos.');
      }

      final googleAuthService = GoogleAuthService(ref);

      final userData = googleAuthService.getUserData(
        widget.account,
        user: user,
        password: password,
        rol: rol,
        country: country,
        address: address,
        age: age,
        genre: genre,
        phone: phone,
        identification: identification,
      );
      final dio = Api(ref).dio;
      final response = await dio.post(
        '/auth/google',
        data: userData,
      );

      final json = response.data;
      final users = LoginResponse.fromJson(json['data']);

      // final controller = UsuariosController(context, ref);
      final controller = ref.read(userCredentialsProvider.notifier);
      controller.setCorreo(users.user.email);
      controller.setTipoRol(users.user.rol);
      controller.setId(users.user.id);

      // OTROS DATOS
      // controller.setFaceid(faceIdToken);
      controller.setTipoAuth("google");
      controller.setToken(users.token);
      
      
      BackgroundServices().restartGPSconnection();
      ref.read(wsConnectionProviderNotifier.notifier).sendMessage({
        "type": "init",
        "userType": users.user.rol.toLowerCase().toString(),
        "userId": users.user.id,
      });

      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      showDialogScope(context, ExceptionsUtils(e).toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ya casi terminamos...'),
        ),
        body: PopScope(
          canPop: false,
          child: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Usuario"),
                onChanged: (value) {
                  setState(() {
                    user = value;
                  });
                },
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Contraseña"),
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                obscureText: true,
              ),
              SelectedRolUsuario(
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      rol = value.name.toUpperCase().toString();
                    });
                  }
                },
              ),
              CardFieldCustom(
                title: "País",
                onChanged: (value) {
                  setState(() {
                    country = value;
                  });
                },
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Dirección"),
                onChanged: (value) {
                  setState(() {
                    address = value;
                  });
                },
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Edad"),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    age = int.tryParse(value) ?? 0;
                  });
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 2,
              ),
              SelectedGenero(
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      genre = value;
                    });
                  }
                },
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Telefono"),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: false, signed: false), // Teclado numérico puro
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    phone = value;
                  });
                },
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("DNI"),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: false, signed: false), // Teclado numérico puro
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    identification = value;
                  });
                },
              ),
              ShadButton(
                width: double.maxFinite,
                onPressed: () async {
                  await _sendUserDataToBackend(
                    user: user,
                    password: password,
                    rol: rol,
                    country: country,
                    address: address,
                    age: age,
                    genre: genre,
                    phone: phone,
                    identification: identification,
                  );
                },
                child: const Text("Enviar"),
              ),
              ShadButton.destructive(
                width: double.maxFinite,
                onPressed: () async {
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: const Text("Confirmación"),
                        content: const Text(
                            "¿Está seguro de cancelar el registro de Google?"),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () => isBackReturn(context),
                            child: const Text("No"),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () async {
                              final googleAuthService = GoogleAuthService(ref);
                              await googleAuthService.signOut();
                              Navigator.pushAndRemoveUntil(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => const SesionPage()),
                                (route) => false,
                              );
                            },
                            child: const Text("Sí"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text("Cancelar registro de google"),
              ),
            ],
          ),
        ));
  }
}
