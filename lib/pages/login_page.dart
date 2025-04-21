// ignore_for_file: use_build_context_synchronously

import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/provider/google_auth.dart';
import 'package:app_viaje_seguro/services/ws_listener_notifier.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginScreenPage extends ConsumerStatefulWidget {
  final RolUsuarioField rol;
  const LoginScreenPage(this.rol, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LoginScreenPageState();
}

class _LoginScreenPageState extends ConsumerState<LoginScreenPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final inputPadding =
      const ShadDecoration(labelPadding: EdgeInsets.symmetric(horizontal: 5));

  bool isObscure = true;

  void togglePasswordVisibility() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              getLogo(size: 200),
              const SizedBox(height: 10),
              Text("Iniciar sesión", style: theme.textTheme.h3),
              ShadInputFormField(
                decoration: inputPadding,
                label: const Text("Usuario"),
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              ShadInputFormField(
                decoration: inputPadding,
                label: const Text("Contraseña"),
                controller: passwordController,
                obscureText: isObscure,
                keyboardType: TextInputType.twitter,
              ),
              ShadSwitch(
                label: const SizedBox(
                    width: double.maxFinite, child: Text("Mostrar contraseña")),
                value: !isObscure,
                onChanged: (value) {
                  togglePasswordVisibility();
                },
              ),
              const SizedBox(height: 10),
              ShadBadge.secondary(
                child: Text(
                  "Bienvenido ${widget.rol.name}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              ShadButton(
                onPressed: () async {
                  showDialogLoading(context);
                  bool response =
                      await UsuariosController(context, ref).authLogin(
                    emailController.text,
                    passwordController.text,
                    AuthType.email,
                  );

                  if (response) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const HomePage()),
                      (route) => false,
                    );
                  }
                },
                width: double.maxFinite,
                child: const Flexible(child: Text("Iniciar sesión")),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
