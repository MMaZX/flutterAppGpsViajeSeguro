import 'package:app_viaje_seguro/controller/material_controller.dart';
import 'package:app_viaje_seguro/model/prediction.dart';
import 'package:app_viaje_seguro/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: FutureCustomWidget(
        future: DashboardController(context: context).getDashboard(),
        widgetBuilder: (context, snapshot) {
          DashboardModel item = snapshot.data;
          return ListView(
            children: [
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                tileColor: Colors.greenAccent.shade400,
                title: const Text(
                  "Verificar viajes activos",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                ),
                subtitle: const Text(
                  "Ingresa y verifica tus viajes actuales",
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () => getStatusActive(context),
              ),
              10.he,
              GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  children: [
                    ContainerModelWidget(
                        title: "Usuarios registrados",
                        data: item.totalUsuarios),
                    ContainerModelWidget(
                        title: "Vehiculos registrados",
                        data: item.totalVehiculos),
                    ContainerModelWidget(
                        title: "Incidencias registradas",
                        data: item.totalIncidencias),
                  ]),
              const ListTile(
                title: Text("Ultimas incidencias"),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: item.modelIncidencias.length,
                itemBuilder: (context, index) {
                  final itemModel = item.modelIncidencias[index];

                  return ListTile(
                    title: Text(
                      "Incidencia(${itemModel.id}) - ${itemModel.dni} -  ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(itemModel.dateTime.toString()),
                  );
                },
              ),
              const ListTile(
                title: Text("Autos en ROJO"),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: item.modelVehiculos.length,
                itemBuilder: (context, index) {
                  final itemModel = item.modelVehiculos[index];

                  return ListTile(
                    title: Text(
                      "Placa:${itemModel.placa} - DNI: ${itemModel.dni}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Total incidencias: ${itemModel.total}"),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}

class ContainerModelWidget extends StatelessWidget {
  final String title;
  final String data;
  const ContainerModelWidget(
      {required this.title, required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
            width: 2,
          )),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 0,
                fontWeight: FontWeight.bold,
              )),
          Text(
            data,
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
