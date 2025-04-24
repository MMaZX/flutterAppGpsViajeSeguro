import 'dart:developer';
import 'dart:ui';
import 'package:app_viaje_seguro/firebase_options.dart';
import 'package:app_viaje_seguro/pages/sesion_page.dart';
import 'package:app_viaje_seguro/provider/permission_provider.dart';
import 'package:app_viaje_seguro/provider/user_credentials/user_credentials_notifier.dart';
import 'package:app_viaje_seguro/services/background_services.dart';
import 'package:app_viaje_seguro/services/location_listener_notifier.dart';
import 'package:app_viaje_seguro/services/notification_listener_notifier.dart';
import 'package:app_viaje_seguro/services/ws_listener_notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_viaje_seguro/provider/theme_cubit.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

String ACCESS_TOKEN =
    "pk.eyJ1IjoiamVhc29uY3VlcyIsImEiOiJjbTJ1bnQ5cTYwMzl5MmlvaW5mY29vOHFhIn0.SRxhLbsSJ0F6GRL5mKXULA";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(ACCESS_TOKEN);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final container = ProviderContainer();
  // ✅ Ejecutar todo dentro del ProviderScope
  await container.read(notificationServiceProvider).initialize();

  final backgroundServices =
      container.read(backgroundServiceControllerProvider.notifier);
  await backgroundServices.initialize();
  await backgroundServices.startService();

  final permissionHandlerServices = container.read(permissionProvider.notifier);
  await permissionHandlerServices.checkPermission();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ProviderContent(),
    ),
  );
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
    
    checkPermissionHandler();
    // Future.microtask(() {
    //   checkPermissionHandler();
    //   ref.read(wsConnectionProvider.notifier).connect();
    //   ref.read(locationStreamProvider.notifier).startLocationStream();
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    
  }

  @override
  didChangeDependencies() {
    checkPermissionHandler();
    super.didChangeDependencies();
    
    checkPermissionHandler();
      //  checkPermissionHandler();
      // ref.read(wsConnectionProvider.notifier).restart();
      // ref.read(locationStreamProvider.notifier).checkPacientesGPS();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("state : $state");
    ref.read(observerAppProvider.notifier).update((state) => state);
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionProvider.notifier).checkPermission();
    checkPermissionHandler();
    }
    super.didChangeAppLifecycleState(state);
  }

  checkPermissionHandler() async {
    // if(mounted) {
    //   ref.read(wsConnectionProvider.notifier).restart();
    //   ref.read(locationStreamProvider.notifier).checkPacientesGPS();
    // }
  }

  void checkRolEnForeground() async {
    final tipoRol = ref.read(userCredentialsProvider).tipoRol;
    debugPrint("👤 Rol detectado en el widget: $tipoRol");
  }

  @override
  Widget build(BuildContext context) {
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
                  centerTitle: true,
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
      brightness: Brightness.dark,
      colorScheme: const ShadVioletColorScheme.dark(
        background: Color(0xff030712),
        foreground: Color(0xfff9fafb),
        card: Color(0xff030712),
        cardForeground: Color(0xfff9fafb),
        popover: Color(0xff030712),
        popoverForeground: Color(0xfff9fafb),
        primary: Color(0xff8333a4),
        primaryForeground: Color(0xfff9fafb),
        secondary: Color(0xff1f2937),
        secondaryForeground: Color(0xfff9fafb),
        muted: Color(0xff1f2937),
        mutedForeground: Color(0xff9ca3af),
        accent: Color(0xff1f2937),
        accentForeground: Color(0xfff9fafb),
        destructive: Color(0xff7f1d1d),
        destructiveForeground: Color(0xfff9fafb),
        border: Color(0xff1f2937),
        input: Color(0xff1f2937),
        ring: Color(0xff8333a4),
        selection: Color(0xFF355172),
      ),
    );
  }

  getLightTheme() {
    return ShadThemeData(
      radius: getBorderRadius(),
      brightness: Brightness.light,
      colorScheme: const ShadVioletColorScheme.light(
        background: Color(0xffffffff),
        foreground: Color(0xff030712),
        card: Color(0xffffffff),
        cardForeground: Color(0xff030712),
        popover: Color(0xffffffff),
        popoverForeground: Color(0xff030712),
        primary: Color(0xff8333a4),
        primaryForeground: Color(0xfff9fafb),
        secondary: Color(0xfff3f4f6),
        secondaryForeground: Color(0xff111827),
        muted: Color(0xfff3f4f6),
        mutedForeground: Color(0xff6b7280),
        accent: Color(0xfff3f4f6),
        accentForeground: Color(0xff111827),
        destructive: Color(0xffef4444),
        destructiveForeground: Color(0xfff9fafb),
        border: Color(0xffe5e7eb),
        input: Color(0xffe5e7eb),
        ring: Color(0xff8333a4),
        selection: Color(0xFFB4D7FF),
      ),
    );
  }

  BorderRadius getBorderRadius() {
    return BorderRadius.circular(10);
  }
}
