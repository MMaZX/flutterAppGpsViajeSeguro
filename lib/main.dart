import 'dart:developer';

import 'package:app_viaje_seguro/config/api.dart';
import 'package:app_viaje_seguro/config/shared_preferences.dart';
import 'package:app_viaje_seguro/controller/vehiculo_controller.dart';
import 'package:app_viaje_seguro/pages/conductor_page.dart';
import 'package:app_viaje_seguro/pages/maps_restore.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/provider/permission_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// My packages
import 'package:app_viaje_seguro/config/theme.dart';
import 'package:app_viaje_seguro/provider/theme_cubit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderContent());
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
}

class ProviderContent extends StatelessWidget {
  const ProviderContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MultiBlocProvider(providers: [
      BlocProvider(
        create: (context) => ThemeCubit(),
      ),
    ], child: const App()));
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Viaje Seguro',
          theme: ThemeApp.getLight(),
          darkTheme: ThemeApp.getDark(),
          themeMode: state ? ThemeMode.dark : ThemeMode.light,
          home: const SesionPage(),
        );
      },
    );
  }
}
