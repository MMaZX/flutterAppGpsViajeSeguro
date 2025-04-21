import 'package:web_socket_channel/web_socket_channel.dart';

class WsConnectionState {
  final WebSocketChannel? channel;
  final bool isConnected;
  final String status;

  const WsConnectionState({
    this.channel,
    this.isConnected = false,
    this.status = "No iniciado",
  });

  WsConnectionState copyWith({
    WebSocketChannel? channel,
    bool? isConnected,
    String? status,
  }) =>
      WsConnectionState(
        channel: channel ?? this.channel,
        isConnected: isConnected ?? this.isConnected,
        status: status ?? this.status,
      );
}
