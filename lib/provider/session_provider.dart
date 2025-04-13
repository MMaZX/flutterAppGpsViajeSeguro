// Primero, asegúrate de tener estas dependencias en tu pubspec.yaml:
// flutter_riverpod: ^2.3.6
// shared_preferences: ^2.1.1

import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

// La clave para guardar la IP en SharedPreferences
const String ipAddressKey = 'ip_address';
const String defaultIpAddress = 'http://192.168.1.129/api-alzsafe/public/api';

// Clase que representa el estado de la conexión
class ConnectionState {
  final String ipAddress;
  final bool isConnected;

  ConnectionState({
    required this.ipAddress,
    this.isConnected = false,
  });

  ConnectionState copyWith({
    String? ipAddress,
    bool? isConnected,
  }) {
    return ConnectionState(
      ipAddress: ipAddress ?? this.ipAddress,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

// StateNotifier para manejar la lógica y el estado de la conexión
class ConnectionNotifier extends StateNotifier<ConnectionState> {
  ConnectionNotifier() : super(ConnectionState(ipAddress: defaultIpAddress)) {
    _loadSavedIp();
  }

  // Cargar la IP guardada de SharedPreferences
  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString(ipAddressKey) ?? defaultIpAddress;
    state = state.copyWith(ipAddress: savedIp);
  }

  // Actualizar la IP y guardarla en SharedPreferences
  Future<void> updateIpAddress(String newIp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ipAddressKey, newIp);
    state = state.copyWith(ipAddress: newIp);
  }

  // Simular una conexión (podrías reemplazar esto con tu lógica real de conexión)
  Future<void> connect(String conexion, context) async {
    // Aquí iría la lógica real para conectar con la IP
    // Por ahora solo simulamos un retraso y establecemos isConnected en true
    await updateIpAddress(conexion);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se actualizó la IP')),
    );
  }

  // Desconectar
  void disconnect() {
    state = state.copyWith(isConnected: false);
  }
}

// Provider para exponer el StateNotifier
final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
  return ConnectionNotifier();
});

// Ejemplo de uso en un widget
class ConnectionManagerScreen extends ConsumerWidget {
  const ConnectionManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionProvider);
    final connectionNotifier = ref.read(connectionProvider.notifier);
    final ipController = TextEditingController(text: connectionState.ipAddress);
    final theme = ShadTheme.of(context).textTheme;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: SizedBox(
        height: 360,
        width: 500,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Conexión'),
            ),
            body: Column(
              children: [
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Text(
                    "Disponible solo en la versión Beta",
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: theme.p.copyWith(
                      height: 0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        ShadInputFormField(
                          controller: ipController,
                          label: const Text("Dirección ip"),
                          placeholder: const Text("Dirección ip"),
                          decoration: const ShadDecoration(
                              labelPadding:
                                  EdgeInsets.symmetric(horizontal: 8)),
                        ),
                        const Spacer(),
                        ListTile(
                          title: Text(
                            'API_HOST',
                            style: theme.p.copyWith(
                              height: 0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(connectionState.ipAddress),
                        ),
                        ShadButton(
                          onPressed: () => connectionNotifier.connect(
                              ipController.text, context),
                          backgroundColor: Colors.green,
                          child: const Expanded(
                            child: Text('Conectar'),
                          ),
                        ),
                        ShadButton.destructive(
                          onPressed: () => isBackReturn(context),
                          child: const Expanded(
                            child: Text('Volver'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
