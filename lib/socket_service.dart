// socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io' show Platform;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  bool _initialized = false;

  // دالة تحدد العنوان المناسب تلقائياً
  String get _socketUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5500'; // للـ Emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:5500'; // للـ iOS Simulator
    } else {
      return 'http://localhost:5500'; // للويب أو desktop
    }
  }

  void init(String userId) {
    if (_initialized) return;

    socket = IO.io(_socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1000,
    });

    socket.onConnect((_) {
      print(
        '✅ Socket Connected Successfully - URL: $_socketUrl - User: $userId',
      );
      socket.emit('join', {'userId': userId});
    });

    socket.onDisconnect((_) => print('❌ Socket Disconnected'));
    socket.onConnectError((err) => print('❌ Connection Error: $err'));
    socket.onError((err) => print('❌ Socket Error: $err'));

    _initialized = true;
  }

  void on(String event, Function(dynamic) handler) {
    socket.off(event);
    socket.on(event, handler);
  }

  void emit(String event, dynamic data) {
    if (socket.connected) {
      socket.emit(event, data);
    } else {
      print('⚠️ Socket not connected yet!');
    }
  }

  void dispose() {
    socket.dispose();
    _initialized = false;
  }
}
