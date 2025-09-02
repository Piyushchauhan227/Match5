import 'package:match5/const.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  SocketService._privateConstructor();

  static final SocketService _instance = SocketService._privateConstructor();

  factory SocketService() {
    return _instance;
  }

  late IO.Socket socket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void connect() {
    socket = IO.io(
      BASE_URL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setReconnectionAttempts(999999)
          .setReconnectionDelay(500)
          .setReconnectionDelayMax(5000)
          .setTimeout(20000)
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print("socket connected");
      _isConnected = true;
    });

    socket.onDisconnect((_) {
      print("socket disconnect");
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
