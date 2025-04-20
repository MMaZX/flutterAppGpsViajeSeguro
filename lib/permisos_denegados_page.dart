
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';



class PermisosDenegadosPage extends StatelessWidget {
  const PermisosDenegadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '404',
              style: TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Permisos Denegados',
              style: TextStyle(
                fontSize: 24,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Para utilizar esta aplicación correctamente, necesitamos acceder a tu ubicación y a las notificaciones.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                openAppSettings(); // Función del permission_handler para abrir la configuración
              },
              child: const Text('Ir a la Configuración'),
            ),
          ],
        ),
      ),
    );
  }
}
