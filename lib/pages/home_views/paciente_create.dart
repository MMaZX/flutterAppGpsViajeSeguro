import 'package:app_viaje_seguro/config/constants.dart';
import 'package:app_viaje_seguro/controller/paciente_controller.dart';
import 'package:app_viaje_seguro/model/pacientes_model.dart';
import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CrearPacientePage extends ConsumerStatefulWidget {
  const CrearPacientePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CrearPacientePageState();
}

class _CrearPacientePageState extends ConsumerState<CrearPacientePage> {
  ShadDecoration inputDecoration =
      const ShadDecoration(labelPadding: EdgeInsets.symmetric(horizontal: 5));

  BodyCreatePacientes paciente = BodyCreatePacientes();
  @override
  Widget build(BuildContext context) {
    final controller = PacienteController(context, ref);
    final textTheme = ShadTheme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear pacientes"),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              ShadCard(
                padding: const EdgeInsets.all(15),
                title: Text(
                  "Actualizar teléfono de contacto",
                  style: textTheme.h3.copyWith(
                    height: 0,
                    fontSize: 20,
                  ),
                ),
                description: Text(
                  "Ingresa un número para recibir notificaciones por WhatsApp.",
                  style: textTheme.muted.copyWith(
                    height: 0,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  child: ShadInputFormField(
                    decoration: inputDecoration,
                    label: const Text("Teléfono del familiar"),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (p0) => paciente.phone_familiar = p0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ShadCard(
                padding: const EdgeInsets.all(15),
                title: Text(
                  "Crear los datos del paciente",
                  style: textTheme.h3.copyWith(
                    height: 0,
                    fontSize: 20,
                  ),
                ),
                description: Text(
                  "Crea los datos de tu paciente respectivamente, el usuario y contraseña serán utilizados para el acceso a la aplicación.",
                  style: textTheme.muted.copyWith(
                    height: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Usuario del paciente"),
                onChanged: (value) => paciente.user = value,
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Nombres y apellidos del paciente"),
                onChanged: (value) {
                  paciente.name = value;
                },
              ),
              SelectParentesco(
                onChanged: (value) {
                  if (value != null) {
                    paciente.parentesco = value;
                  }
                },
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Correo electrónico"),
                textInputAction: TextInputAction.next,
                onChanged: (value) => paciente.email = value,
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Contraseña"),
                obscureText: true,
                onChanged: (value) => paciente.password = value,
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("DNI"),
                keyboardType: TextInputType.number,
                onChanged: (value) => paciente.dni = value,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 8,
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Edad"),
                keyboardType: TextInputType.number,
                onChanged: (p0) {
                  try {
                    paciente.age = int.parse(p0);
                  } catch (e) {
                    paciente.age = 0;
                  }
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 2,
              ),
              SelectedGenero(
                onChanged: (value) {
                  if (value != null) {
                    paciente.genre = value;
                  }
                },
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Teléfono"),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (p0) => paciente.phone = p0,
              ),
              ShadInputFormField(
                decoration: inputDecoration,
                label: const Text("Dirección"),
                onChanged: (p0) => paciente.address = p0,
              ),
            ],
          )),
          ShadButton(
            onPressed: () async {
              print(paciente.toJson());
              showDialogLoading(context);
              bool value = await controller.createPacientes(paciente);

              if (value) {
                isBackReturn(context);
              }
            },
            width: double.maxFinite,
            child: const Flexible(child: Text("Agregar paciente")),
          )
        ],
      ),
    );
  }
}

class SelectedGenero extends ConsumerStatefulWidget {
  final void Function(String? value)? onChanged;

  const SelectedGenero({
    super.key,
    required this.onChanged,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectedGeneroState();
}

class _SelectedGeneroState extends ConsumerState<SelectedGenero> {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 5),
        child: Text(
          "Seleccionar género",
          style: theme.textTheme.small,
        ),
      ),
      subtitle: SizedBox(
        width: double.maxFinite,
        child: ShadSelect<String>(
          placeholder: const Text("Selecciona un género"),
          options: const [
            ShadOption(value: "MASCULINO", child: Text("MASCULINO")),
            ShadOption(value: "FEMENINO", child: Text("FEMENINO")),
          ],
          selectedOptionBuilder: (context, value) {
            return Text(value.toUpperCase());
          },
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

class SelectParentesco extends ConsumerStatefulWidget {
  final void Function(String? value)? onChanged;

  const SelectParentesco({
    super.key,
    required this.onChanged,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectParentescoState();
}

class _SelectParentescoState extends ConsumerState<SelectParentesco> {
  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 5),
        child: Text(
          "Seleccionar parentesco",
          style: theme.textTheme.small,
        ),
      ),
      subtitle: SizedBox(
        width: double.maxFinite,
        child: ShadSelect<String>(
          placeholder: const Text("Parentesco"),
          options: const [
            ShadOption(value: "PADRE", child: Text("PADRE")),
            ShadOption(value: "MADRE", child: Text("MADRE")),
            ShadOption(value: "HERMANO", child: Text("HERMANO")),
            ShadOption(value: "HERMANA", child: Text("HERMANA")),
            ShadOption(value: "TÍO", child: Text("TÍO")),
            ShadOption(value: "TÍA", child: Text("TÍA")),
            ShadOption(value: "ABUELO", child: Text("ABUELO")),
            ShadOption(value: "ABUELA", child: Text("ABUELA")),
            ShadOption(value: "OTRO", child: Text("OTRO")),
          ],
          selectedOptionBuilder: (context, value) {
            return Text(value.toUpperCase());
          },
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
