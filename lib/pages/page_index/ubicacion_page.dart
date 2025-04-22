import 'package:app_viaje_seguro/pages/maps/map_screen.dart';
import 'package:flutter/material.dart';

class UbicacionIndexPage extends StatelessWidget {
  const UbicacionIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: MapScreen(),
      // body: LocationMapsContent(),
    );
  }
}
