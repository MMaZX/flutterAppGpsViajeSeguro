import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

///[ THEME APP ]
Color primaryColorDark = Colors.blueAccent.shade700;
Color primaryColor = Colors.blueAccent;

const secondaryColor = Color(0XFF184c84);
const backgroundColorLight = Color(0XFFffffff);
const backgroundColorDark = Color(0XFF161719);
Color primaryColorDarkVariant = Colors.blue.shade200;
const onBackgroundColorDark = Color.fromARGB(255, 0, 5, 20);
const onBackgroundColorLight = Color(0XFFeaf0ff);
Color cardValueWhite = Colors.grey.shade200;

const TextStyle styleBlackBold =
    TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
const TextStyle styleBlack = TextStyle(color: Colors.black);
const TextStyle styleBold = TextStyle(fontWeight: FontWeight.bold);
const TextStyle styleWhiteBold =
    TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
const TextStyle styleWhite = TextStyle(color: Colors.white);

class ThemeApp {
  static ThemeData getLight() => ThemeData(
        // splashFactory: InkRipple.splashFactory,
        // visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
        colorScheme: ColorScheme.light(
          brightness: Brightness.light,
          surface: backgroundColorLight,
          primary: primaryColor,
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        useMaterial3: true,
        bottomSheetTheme: const BottomSheetThemeData(
          modalElevation: 0,
          modalBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        dialogTheme: const DialogTheme(elevation: 0),
        cardTheme: const CardTheme(
          elevation: 0,
          color: Color(0XFFF1C27B),
        ),
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        // drawerTheme:
        //     const DrawerThemeData(backgroundColor: onBackgroundColorLight),
      );

  static ThemeData getDark() => ThemeData(
        // splashFactory: InkRipple.splashFactory,
        // visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
        colorScheme: ColorScheme.dark(
          brightness: Brightness.dark,
          surface: backgroundColorDark,
          primary: primaryColorDark,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          modalElevation: 0,
          modalBackgroundColor: Colors.grey.shade900,
          backgroundColor: Colors.grey.shade900,
          elevation: 0,
        ),
        dialogTheme: const DialogTheme(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 20, 20, 20),
        ),
        fontFamily: GoogleFonts.poppins().fontFamily,
        useMaterial3: true,
        cardTheme: const CardTheme(
          elevation: 0,
          color: Color(0XFFF1C27B),
        ),
        appBarTheme: const AppBarTheme(
          surfaceTintColor: Colors.transparent,
          elevation: 1,
          centerTitle: false,
        ),
        // drawerTheme:
        //     const DrawerThemeData(backgroundColor: onBackgroundColorDark),
      );

  // List<Object?> get props => [];
}
