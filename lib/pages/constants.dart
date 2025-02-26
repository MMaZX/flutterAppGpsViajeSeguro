import 'package:flutter/material.dart';

const String apiKey = "Your key";

const Color primaryColor = Color(0xFF006491);
const Color textColorLightTheme = Color(0xFF0D0D0E);

const Color secondaryColor80LightTheme = Color(0xFF202225);
const Color secondaryColor60LightTheme = Color(0xFF313336);
const Color secondaryColor40LightTheme = Color(0xFF585858);
const Color secondaryColor20LightTheme = Color(0xFF787F84);
const Color secondaryColor10LightTheme = Color(0xFFEEEEEE);
const Color secondaryColor5LightTheme = Color(0xFFF8F8F8);

const defaultPadding = 16.0;

class EmptyWidget extends StatelessWidget {
  final String data;
  const EmptyWidget(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      child: Text(
        data,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, height: 0),
      ),
    );
  }
}

RoundedRectangleBorder borderDialog = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(10),
);
