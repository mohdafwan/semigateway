import 'dart:convert';

import 'package:ctelnet/ctelnet.dart';
import 'dart:async';

class TcpConnection {
  static final TcpConnection _instance = TcpConnection._internal();
  factory TcpConnection() => _instance;
  TcpConnection._internal();

  CTelnetClient? _client;
  StreamController<String> messageController =
      StreamController<String>.broadcast();

  final StreamController<Map<dynamic, dynamic>> dataController =
      StreamController<Map<dynamic, dynamic>>.broadcast();

  bool isConnected = false;
  List<int> _buffer = [];

  Future<Map<String, dynamic>> sendHexCommandAndWaitResponse(
    List<int> command, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    // Send the command
    await sendHexCommand(command);

    try {
      final response = await messageController.stream
          .timeout(timeout)
          .firstWhere((message) => message.contains('Data Is Responsed'));

      return {'success': true, 'data': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<bool> connect(String host, int port) async {
    try {
      _client = CTelnetClient(
        host: "192.168.4.1",
        port: 23,
        timeout: const Duration(seconds: 30),
        onConnect: () {
          isConnected = true;
          messageController.add('Connected');
        },
        onDisconnect: () {
          isConnected = false;
          messageController.add('Disconnected');
        },
        onError: (error) => messageController.add('Error: $error'),
      );

      final stream = await _client?.connect();

      stream?.listen(
        (data) {
          if (data.text.isNotEmpty) {
            final bytes = data.text.codeUnits;
            _buffer.addAll(bytes);
            _processBuffer();
          }
        },
        onError: (error) => messageController.add('Stream error: $error'),
        onDone: () => messageController.add('Stream closed'),
      );

      return true;
    } catch (e) {
      messageController.add('Connection error: $e');
      return false;
    }
  }

  void _processBuffer() {
    while (_buffer.length >= 6) {
      final sof = _buffer[0];
      final fc = _buffer[1];
      final ff = _buffer[2];
      final ft = _buffer[3];
      final dl = _buffer[4];

      if (_buffer.length < 5 + dl + 2) {
        return;
      }

      final frame = _buffer.sublist(0, 5 + dl + 2);
      _buffer = _buffer.sublist(5 + dl + 2);

      _parseReceivedData(frame);
    }
  }

  void _parseReceivedData(List<int> bytes) {
    if (bytes.length < 6) return; // Minimum frame size

    final sof = bytes[0];
    final fc = bytes[1];
    final ff = bytes[2];
    final ft = bytes[3];

    // Check if it's a data frame (0x44)
    if (ft == 0x44) {
      final dl = bytes[4];
      final dataBytes = bytes.sublist(5, 5 + dl);
      String data;
      try {
        data = utf8.decode(dataBytes);
      } catch (e) {
        data = dataBytes.map((b) => b.toRadixString(16)).join(' ');
      }

      final hexData =
          dataBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

      dataController.add({
        'fc': fc,
        'ff': ff,
        'data': data,
      });

      // Log detailed information
      messageController.add('FC: ${fc.toRadixString(16)}');
      messageController.add('FF: ${ff.toRadixString(16)}');
      messageController.add('Data: $hexData');
    }
  }

  Future<void> sendHexCommand(List<int> bytes) async {
    try {
      _client?.sendBytes(bytes);
      final hexString =
          bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      messageController.add('Sent hex: $hexString');
    } catch (e) {
      messageController.add('Error sending data: $e');
    }
  }

  void disconnect() {
    _client?.disconnect();
    isConnected = false;
  }

  void dispose() {
    disconnect();
    messageController.close();
  }
}
