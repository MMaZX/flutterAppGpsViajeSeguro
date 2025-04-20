import 'package:app_viaje_seguro/pages/maps/map_paciente.dart';
import 'package:app_viaje_seguro/pages/maps/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UbicacionIndexPage extends ConsumerStatefulWidget {
  const UbicacionIndexPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UbicacionIndexPageState();
}

class _UbicacionIndexPageState extends ConsumerState<UbicacionIndexPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MapScreen(),
      // body: LocationMapsContent(),
    );
  }
}
