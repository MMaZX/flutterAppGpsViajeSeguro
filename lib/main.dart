import 'dart:developer';
import 'package:app_viaje_seguro/pages/biometric_page.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/provider/permission_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'firebase_options.dart';
// My packages
import 'package:app_viaje_seguro/config/theme.dart';
import 'package:app_viaje_seguro/provider/theme_cubit.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderContent());
}

class ProviderContent extends StatelessWidget {
  const ProviderContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: const App(),
    ));
  }
}

class App extends ConsumerStatefulWidget {
  const App({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(permissionProvider.notifier).checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("state : $state");
    ref.read(observerAppProvider.notifier).update((state) => state);
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionProvider.notifier).checkPermission();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    // final theme = context.watch<ThemeCubit>();
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, state) {
        return ShadApp.material(
          title: 'GR Manager',
          materialThemeBuilder: (context, theme) {
            return ThemeData(
              fontFamily: 'Inter',
              useMaterial3: true,
              colorScheme: theme.colorScheme,
              appBarTheme: AppBarTheme(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  titleTextStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 0,
                    fontFamily: 'Inter',
                  )),
            );
          },
          theme: ShadAppTheme().getLightTheme(),
          darkTheme: ShadAppTheme().getDarkTheme(),
          debugShowCheckedModeBanner: false,
          themeCurve: Curves.fastLinearToSlowEaseIn,
          themeMode: state ? ThemeMode.light : ThemeMode.dark,
          home: const SesionPage(),
        );
      },
    );
  }
}

class ShadAppTheme {
  getDarkTheme() {
    return ShadThemeData(
      radius: getBorderRadius(),
      brightness: Brightness.light,
      colorScheme: ShadColorScheme.fromName(
        'violet',
        brightness: Brightness.light,
      ),
    );
  }

  getLightTheme() {
    return ShadThemeData(
      radius: getBorderRadius(),
      brightness: Brightness.dark,
      colorScheme: ShadColorScheme.fromName(
        'violet',
        brightness: Brightness.dark,
      ),
    );
  }

  BorderRadius getBorderRadius() {
    return BorderRadius.circular(10);
  }
}
