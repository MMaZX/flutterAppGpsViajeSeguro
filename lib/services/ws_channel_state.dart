import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class WSChannelState {
  final bool isEnabled;
  final String context;

  const WSChannelState({
    required this.isEnabled,
    required this.context,
  });

  // Método para copiar el estado con nuevos valores
  WSChannelState copyWith({
    bool? isEnabled,
    String? context,
  }) {
    return WSChannelState(
      isEnabled: isEnabled ?? this.isEnabled,
      context: context ?? this.context,
    );
  }
}

final wsChannelStateProvider =
    StateNotifierProvider<WSChannelStateConnection, WSChannelState>(
  (ref) => WSChannelStateConnection(),
);



class WSChannelStateConnection extends StateNotifier<WSChannelState> {
  WSChannelStateConnection()
      : super(const WSChannelState(isEnabled: false, context: ''));

  void setConnection(bool isEnabled) {
    state = state.copyWith(isEnabled: isEnabled);
  }

  void setContext(String newContext) {
    state = state.copyWith(context: newContext);
    sendMessage(newContext);
  }

  void sendMessage(dynamic message) {
    if (!state.isEnabled) {
      log('❌ No conectado. No se puede enviar el mensaje.');
      return;
    }

    log('📤 CONTEXTO "${state.context}": $message');
  }
}
