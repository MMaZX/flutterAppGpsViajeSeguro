import 'package:app_viaje_seguro/provider/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextFormCustom extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Color? color;
  final Color? backgroundColor;
  final Color? textHintColor;

  final int? maxLenght;
  const TextFormCustom(
      {super.key,
      this.controller,
      this.hintText,
      this.obscureText = false,
      this.onChanged,
      this.inputFormatters,
      this.keyboardType,
      this.maxLenght,
      this.color,
      this.backgroundColor,
      this.textHintColor});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return TextFormField(
          controller: controller,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          maxLength: maxLenght,
          decoration: InputDecoration(
            counter: const SizedBox(),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: color ?? colorsThemeDefault(context),
                width: 2.0,
              ),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: textHintColor ??
                  (!state ? const Color(0xFF0e0e10) : Colors.white),
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
            fillColor: backgroundColor ??
                (state ? const Color(0xFF0e0e10) : Colors.white),
            filled: true,
          ),
          onChanged: onChanged,
          obscureText: obscureText,
        );
      },
    );
  }
}

Color colorsThemeDefault(context) {
  return Theme.of(context).colorScheme.primary;
}

class IconChangeTheme extends StatelessWidget {
  const IconChangeTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return IconButton(
            onPressed: () {
              context.read<ThemeCubit>().setTheme(!state);
            },
            icon: Icon(
                state ? Icons.dark_mode_rounded : Icons.light_mode_rounded));
      },
    );
  }
}

extension NumExtension on num {
  Widget get wi => SizedBox(width: toDouble());
  Widget get he => SizedBox(height: toDouble());
}

class FutureCustomWidget extends StatefulWidget {
  final Future future;
  final Widget? customLoading;
  final Widget Function(BuildContext context, dynamic snapshot) widgetBuilder;
  const FutureCustomWidget(
      {super.key,
      required this.future,
      required this.widgetBuilder,
      this.customLoading});

  @override
  State<FutureCustomWidget> createState() => _FutureCustomWidgetState();
}

class _FutureCustomWidgetState extends State<FutureCustomWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.customLoading ??
              const Center(child: Text("Cargando..."));
        } else if (snapshot.hasError) {
          // print(snapshot.error);
          return Center(child: Text("Error ${snapshot.error}"));
        } else {
          // return widget;
          if (snapshot.data == null) {
            return const Text("Validando...");
          } else {
            return widget.widgetBuilder(context, snapshot);
          }
        }
      },
    );
  }
}
