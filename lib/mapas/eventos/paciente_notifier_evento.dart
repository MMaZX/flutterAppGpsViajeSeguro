import 'package:app_viaje_seguro/mapas/eventos/paciente_location_evento.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientLocationsProvider = StateNotifierProvider<PatientLocationNotifier,
    Map<String, PatientLocation>>(
  (ref) => PatientLocationNotifier(),
);

class PatientLocationNotifier
    extends StateNotifier<Map<String, PatientLocation>> {
  PatientLocationNotifier() : super({});

  void updateLocation(PatientLocation location) {
    state = {
      ...state,
      location.patientId: location,
    };
  }

  PatientLocation? getLocation(String patientId) => state[patientId];
}



final patientLocationStreamProvider =
    Provider.family<PatientLocation?, String>((ref, patientId) {
  return ref.watch(patientLocationsProvider)[patientId];
});
