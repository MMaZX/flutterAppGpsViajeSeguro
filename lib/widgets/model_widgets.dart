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
