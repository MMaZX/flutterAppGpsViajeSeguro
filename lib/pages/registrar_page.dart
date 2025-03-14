// ignore_for_file: use_build_context_synchronously

import 'package:app_viaje_seguro/controller/usuarios_controller.dart';
import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/pages/home_page.dart';
import 'package:app_viaje_seguro/widgets/modal_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// My packages
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RegistrarPage extends ConsumerStatefulWidget {
  const RegistrarPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegistrarPageState();
}

class _RegistrarPageState extends ConsumerState<RegistrarPage> {
  final inputDecoration =
      const ShadDecoration(labelPadding: EdgeInsets.symmetric(horizontal: 5));

  BodyCreateUsuarios bodyModel = BodyCreateUsuarios();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Registrate",
          style: TextStyle(fontWeight: FontWeight.bold, height: 0),
        ),
        actions: const [
          IconChangeTheme(),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ListView(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                height: 200,
                width: 200,
                decoration: const BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                    child: Text(
                  "Agrega\nuna Foto",
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    height: 0,
                  ),
                )),
              ),
            ),
            ShadInputFormField(
              decoration: inputDecoration,
              label: const Text("Nombres"),
              onChanged: (value) => bodyModel.name = value,
            ),
            ShadInputFormField(
              decoration: inputDecoration,
              label: const Text("Apellidos"),
              onChanged: (value) => bodyModel.lastName = value,
            ),
            // ShadInputFormField(
            //   decoration: inputDecoration,
            //   label: const Text("Nombre de usuario"),
            //   onChanged: (value) => bodyModel.email = value,
            // ),
            SelectedRolUsuario(
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    bodyModel.rol = value.name.toUpperCase().toString();
                  });
                }
              },
            ),
            ShadInputFormField(
              decoration: inputDecoration,
              label: const Text("DNI"),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: false, signed: false), // Teclado numérico puro
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],

              onChanged: (value) => bodyModel.identification = value,
            ),

            ShadInputFormField(
              decoration: inputDecoration,
              label: const Text("Correo"),
              onChanged: (value) => bodyModel.email = value,
            ),
            ShadInputFormField(
              decoration: inputDecoration,
              label: const Text("Contraseña"),
              onChanged: (value) => bodyModel.password = value,
              obscureText: true,
            ),
            ShadInputFormField(
              decoration: inputDecoration,
              label: const Text("Dirección"),
              onChanged: (value) => bodyModel.address = value,
              obscureText: true,
            ),
            ShadButton(
              width: double.maxFinite,
              onPressed: () async {
                showDialogLoading(context);

                bodyModel.country = "PERU";
                final value = await UsuariosController(context, ref)
                    .createUsuarios(bodyModel);

                if (value) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                }
                //
              },
              child: const Flexible(child: Text("Registrar usuario")),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedRolUsuario extends ConsumerStatefulWidget {
  final void Function(RolUsuarioField? value)? onChanged;

  const SelectedRolUsuario({
    super.key,
    required this.onChanged,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectedRolUsuarioState();
}

class _SelectedRolUsuarioState extends ConsumerState<SelectedRolUsuario> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: ShadSelect<RolUsuarioField>(
        placeholder: const Text("Selecciona un rol"),
        options: List.generate(
          RolUsuarioField.values.length,
          (index) {
            RolUsuarioField item = RolUsuarioField.values[index];
            return ShadOption(
              value: item,
              child: Text(
                item.name.toUpperCase().toString(),
              ),
            );
          },
        ),
        selectedOptionBuilder: (context, value) {
          return Text(value.name.toUpperCase());
        },
        onChanged: widget.onChanged,
      ),
    );
  }
}
