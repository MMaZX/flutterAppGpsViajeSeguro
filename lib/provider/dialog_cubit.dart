import 'package:app_viaje_seguro/widgets/model_widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class DialogState {}

class DialogInitial extends DialogState {}

class DialogLoading extends DialogState {}

class DialogResult extends DialogState {
  final String message;
  final bool isSuccess;

  DialogResult({required this.message, required this.isSuccess});
}

class DialogCubit extends Cubit<DialogState> {
  DialogCubit() : super(DialogInitial());

  void showLoading() => emit(DialogLoading());

  void showResult(String message, bool isSuccess) =>
      emit(DialogResult(message: message, isSuccess: isSuccess));
}

getDialog(DialogState state, context) {
  if (state is DialogLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  } else if (state is DialogResult) {
    // Mostrar diálogo con el mensaje de resultado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(state.isSuccess ? 'Éxito' : 'Error'),
            content: Text(state.message),
            actions: [
              CupertinoButton(
                child: const Text('Aceptar'),
                onPressed: () => isBackReturn(context),
              ),
            ],
          );
        },
      );
    });
  }
}
