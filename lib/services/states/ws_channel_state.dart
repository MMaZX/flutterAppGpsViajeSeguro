import 'dart:developer';

import 'package:web_socket_channel/web_socket_channel.dart';

enum WebSocketStatus { connecting, connected, disconnected, error }

class WsConnectionState {
  final WebSocketChannel? channel;
  final WebSocketStatus status;
  final String message;

  const WsConnectionState({
    this.channel,
    this.status = WebSocketStatus.disconnected,
    this.message = "-",
  });

  WsConnectionState copyWith({
    WebSocketChannel? channel,
    WebSocketStatus? status,
    String? message,
  }) {
    final updatedState = WsConnectionState(
      channel: channel ?? this.channel,
      status: status ?? this.status,
      message: message ?? this.message,
    );

    log('WsConnectionState updated: '
        'channel: ${channel != null ? "⚡" : "💤"}, '
        'status: ${status != null ? status.name.toUpperCase() : "null"}, '
        'message: ${message != null ? message.toString() : "null"}');

    return updatedState;
  }
}
