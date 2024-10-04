import 'package:app_viaje_seguro/model/usuarios_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedRolDropdownProvider = StateProvider<String>((ref) {
  return modelRol.first;
});
