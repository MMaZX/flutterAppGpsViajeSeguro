import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/api_controller.dart';
import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:app_viaje_seguro/pages/formulario_sesion_google_page.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/pages/login_page.dart';
import 'package:app_viaje_seguro/pages/registrar_page.dart';
import 'package:app_viaje_seguro/provider/google_auth.dart';
import 'package:app_viaje_seguro/provider/session_provider.dart';
import 'package:app_viaje_seguro/provider/theme_cubit.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SesionPage extends ConsumerStatefulWidget {
  const SesionPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SesionPageState();
}

class _SesionPageState extends ConsumerState<SesionPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    final googleAuthService = GoogleAuthService(ref);
    setState(() {
      _isLoading = true;
    });

    try {
      final account = await googleAuthService.signIn();

      if (account != null) {
        // Obtén los datos del usuario para enviar al backend
        // Aquí puedes enviar los datos al backend
        // await _sendUserDataToBackend();

        try {
          final dio = Api(ref).dio;
          final response = await dio.post(
            '/auth/google',
            data: {
              'email': account.email,
            },
          );

          final json = response.data;
          final users = LoginResponse.fromJson(json['data']);
          if (users.token.isNotEmpty) {
            final controller = UsuariosController(context, ref);
            controller.setCorreo(users.user.email);
            controller.setTipoRol(users.user.rol);
            controller.setId(users.user.id.toString());

            // OTROS DATOS
            // controller.setFaceid(faceIdToken);
            controller.setTipoAuth("google");
            controller.setToken(users.token);
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(builder: (context) => const HomePage()),
              (route) => false,
            );
            return;
          }
        } catch (e) {
          if (ExceptionsUtils(e).toString().toLowerCase().contains("faltan")) {
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    FormularioSesionGooglePage(account: account),
              ),
              (route) => false,
            );
          } else {
            rethrow;
          }
        }
      }
    } catch (e) {
      showDialogScope(context, ExceptionsUtils(e).toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
              // backgroundColor: Colors.transparent,
              actions: [
                ShadButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const ConnectionManagerScreen(),
                  ),
                  icon: const Icon(LucideIcons.command),
                ),
                const IconChangeTheme(),
              ],
            ),
            body: Center(
              child: Container(
                width: 300,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "ALZSAFE",
                      style: textTheme.h1,
                    ),
                    getLogo(size: 200, padding: 15),

                    const SizedBox(height: 30),
                    ShadButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const LoginScreenPage(
                                  RolUsuarioField.familiar),
                            ));
                      },
                      width: double.maxFinite,
                      child: const Flexible(
                        child: Text(
                          "Familiar o cuidador",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(height: 10),
                    ShadButton(
                      width: double.maxFinite,
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const LoginScreenPage(
                                  RolUsuarioField.paciente),
                            ));
                      },
                      child: const Flexible(
                        child: Text(
                          "Paciente",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    ShadButton.outline(
                      width: double.maxFinite,
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const RegistrarPage()),
                        );
                      },
                      child: const Text(
                        "Registrarte",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),

                    Row(
                      children: [
                        const Expanded(
                            child: Opacity(opacity: 0.4, child: Divider())),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: const Text("O continua con"),
                        ),
                        const Expanded(
                            child: Opacity(opacity: 0.4, child: Divider())),
                      ],
                    ),

                    _isLoading
                        ? const CircularProgressIndicator()
                        : GoogleSignInButton(
                            onPressed: _handleGoogleSignIn,
                          ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}
