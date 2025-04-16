import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/usuario_model.dart';
import 'package:app_viaje_seguro/pages/registrar_page.dart';
import 'package:app_viaje_seguro/pages/widgets_constants.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
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
  UsuarioModelData? _usuario;
  bool _isLoading = true;
  String? _errorMessage;

  // @override
  // void initState() {
  //   super.initState();

  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final controller = UsuariosController(context, ref);
      final userData = await controller.getUsersById();
      setState(() {
        _usuario = userData;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    if (_usuario == null) {
      return const Center(child: Text('No user data available.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Información de usuario"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const SizedBox(height: 10),
          CardFieldCustom(
            title: "Nombre",
            subtitle: _usuario!.name,
            onChanged: (value) {
              setState(() {
                _usuario = _usuario?.copyWith(name: value);
              });
            },
          ),
          CardFieldCustom(
            title: "Usuario",
            subtitle: _usuario!.user,
            onChanged: (value) {
              setState(() {
                _usuario = _usuario?.copyWith(user: value);
              });
            },
          ),
          CardFieldCustom(
            title: "Dirección",
            subtitle: _usuario!.address,
            onChanged: (value) {
              setState(() {
                _usuario = _usuario?.copyWith(address: value);
              });
            },
          ),
          CardFieldCustom(
            title: "Correo Electrónico",
            subtitle: _usuario!.email,
            onChanged: (value) {
              setState(() {
                _usuario = _usuario?.copyWith(email: value);
              });
            },
          ),
          CardFieldCustom(
            title: "DNI",
            subtitle: _usuario!.identification,
            onChanged: (value) {
              setState(() {
                _usuario = _usuario?.copyWith(identification: value);
              });
            },
          ),
          CardFieldCustom(
            title: "País",
            subtitle: _usuario!.country,
            onChanged: (value) {
              setState(() {
                _usuario = _usuario?.copyWith(country: value);
              });
            },
          ),
          ShadButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String password = "";
                  return AlertDialog(
                    title: const Text("Confirmar acción"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                            "Por favor, confirma tu acción ingresando tu contraseña."),
                        const SizedBox(height: 10),
                        ShadInputFormField(
                          decoration: const ShadDecoration(
                              labelPadding:
                                  EdgeInsets.symmetric(horizontal: 5)),
                          label: const Text("Contraseña"),
                          obscureText: true,
                          onChanged: (value) {
                            password = value;
                          },
                        ),
                      ],
                    ),
                    actions: [
                      ShadButton.outline(
                        onPressed: () => isBackReturn(context),
                        child: const Text("Cancelar"),
                      ),
                      ShadButton.secondary(
                        onPressed: () {
                          if (password.isNotEmpty) {
                            if (_usuario != null) {
                              UsuariosController(context, ref)
                                  .updateUsuario(_usuario!, password);
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Por favor, ingresa tu contraseña.")),
                            );
                          }
                        },
                        child: const Text("Confirmar"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text("Editar información de usuario"),
          ),
        ],
      ),
    );
  }
}

class CardFieldCustom extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function(String)? onChanged;

  const CardFieldCustom({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ShadCard(
        // backgroundColor: Colors.transparent,
        rowMainAxisAlignment: MainAxisAlignment.start,
        padding: const EdgeInsets.all(15),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: theme.p.copyWith(
              height: 0,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        description: ShadInput(initialValue: subtitle, onChanged: onChanged),
      ),
    );
  }
}
