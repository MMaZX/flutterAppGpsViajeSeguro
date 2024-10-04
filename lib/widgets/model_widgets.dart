import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:app_viaje_seguro/provider/model_provider.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

isBackReturn(context) {
  if (Navigator.canPop(context)) {
    Navigator.of(context).pop();
  }
}

class RolDropdownCustom extends ConsumerStatefulWidget {
  const RolDropdownCustom({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RolDropdownCustomState();
}

class _RolDropdownCustomState extends ConsumerState<RolDropdownCustom> {
  final BorderRadius _borderRadius = BorderRadius.circular(15);
  @override
  Widget build(BuildContext context) {
    final valueSelected = ref.watch(selectedRolDropdownProvider);
    return Container(
      decoration: BoxDecoration(
          borderRadius: _borderRadius,
          border: Border.all(color: colorsThemeDefault(context))),
      child: DropdownButton<String>(
        items: List.generate(
          modelRol.length,
          (index) {
            final item = modelRol[index].toUpperCase().toString();
            return DropdownMenuItem(value: item, child: Text(item));
          },
        ),
        value: valueSelected,
        elevation: 0,
        alignment: Alignment.center,
        isDense: true,
        isExpanded: true,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        borderRadius: _borderRadius,
        underline: const SizedBox.shrink(),
        onChanged: (value) {
          ref
              .read(selectedRolDropdownProvider.notifier)
              .update((state) => value!);
        },
      ),
    );
  }
}

class ButtonCustomBase extends StatelessWidget {
  final Function()? onPressed;
  final String title;
  final double borderRadius;
  final Color? color;
  final Color? colorText;
  final double minWidth;
  final EdgeInsetsGeometry padding;

  const ButtonCustomBase(
      {super.key,
      required this.onPressed,
      required this.title,
      this.borderRadius = 15,
      this.color,
      this.colorText,
      this.minWidth = double.maxFinite,
      this.padding = const EdgeInsets.only(top: 15)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: MaterialButton(
        minWidth: minWidth,
        disabledColor: Colors.grey,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius)),
        color: color ?? Theme.of(context).colorScheme.primary,
        // padding: EdgeInsets.all(10),
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colorText ?? Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
