import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/pages/constants.dart';
import 'package:app_viaje_seguro/pages/login_page.dart';
import 'package:app_viaje_seguro/pages/registrar_page.dart';
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
                  ],
                ),
              ),
            ));
      },
    );
  }
}
