import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<bool> {
  ThemeCubit() : super(false);
  //key Mode
  String keyTheme = "isTheme";

  //functions hared preferences
  Future setTheme(bool isMode) async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setBool(keyTheme, isMode);
    emit(isMode);
  }

  Future getTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final isMode = preferences.getBool(keyTheme);

    if (isMode != null) {
      emit(isMode);
    } else {
      preferences.setBool(keyTheme, false);
    }
    emit(isMode!);
  }
}
