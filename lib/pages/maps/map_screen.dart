import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart'; // Para clustering de marcadores
import 'package:flutter_map_cache/flutter_map_cache.dart'; // Para caché de tiles

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  final int _numMarkers = 1000;

  @override
  void initState() {
    super.initState();
    _generateRandomMarkers(_numMarkers);
  }

  void _generateRandomMarkers(int count) {
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < count; i++) {
      final lat = -90 + 180 * (random % (i + 1)) / (i + 1);
      final lng = -180 + 360 * ((random + i) % (i + 1)) / (i + 1);
      _markers.add(
        Marker(
          width: 30,
          height: 30,
          point: LatLng(lat, lng),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.location_on, color: Colors.white),
          ),
          // builder: (ctx) => const Icon(Icons.location_pin, color: Colors.red),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Map - Rendimiento')),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
            maxZoom: 18,
            // initialCenter: locationNow,
            initialZoom: 18,
            onTap: (tapPosition, point) {
              // ref.read(listMarketContainerProvider).add(point);
            }),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ALZSAFE',
            tileProvider: NetworkTileProvider(),
          ),
          // Uso de MarkerClusterLayer para manejar grandes cantidades de marcadores
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 120,
              disableClusteringAtZoom:
                  16, // Deshabilitar clustering a zoom alto
              size: const Size(40, 40),
              // anchor: AnchorPos.align(AnchorAlign.center),
              builder: (context, markers) {
                return Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue.withOpacity(0.7)),
                  child: Center(
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            // markers: _markers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(const LatLng(-12.0900, -77.0283), 12);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
