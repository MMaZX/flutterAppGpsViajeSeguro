import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BiometricPage extends ConsumerStatefulWidget {
  const BiometricPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BiometricPageState();
}

class _BiometricPageState extends ConsumerState<BiometricPage> {
  LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            FutureCustomWidget(
              future: auth.isDeviceSupported(),
              customLoading: const Center(
                child: CircularProgressIndicator(),
              ),
              widgetBuilder: (context, snapshot) {
                bool isSupported = snapshot.data;
                return ListTile(
                  title: const Text(
                    "Soporte de Biométricos",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    isSupported
                        ? "Tu dispositivo soporta validación por biométricos"
                        : "Tu dispositivo no soporta protección de biométricos",
                  ),
                  onTap: () {
                    setState(() {});
                  },
                  trailing:
                      const ShadImage.square(LucideIcons.fingerprint, size: 18),
                );
              },
            ),
            // FutureCustomWidget(
            //   future: auth.getAvailableBiometrics(),
            //   widgetBuilder: (context, snapshot) {
            //     List<BiometricType> list = snapshot.data;

            //     return ListView.builder(
            //       shrinkWrap: true,
            //       physics: const NeverScrollableScrollPhysics(),
            //       itemCount: list.length,
            //       itemBuilder: (context, index) {
            //         final bio = list[index];
            //         return ListTile(title: Text(bio.name));
            //       },
            //     );
            //   },
            // )
          ],
        ),
      ),
    );
  }
}
