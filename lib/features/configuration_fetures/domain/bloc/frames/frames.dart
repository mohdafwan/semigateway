// ignore_for_file: avoid_print

import 'package:semicalibration/features/configuration_fetures/domain/repository/tcp_connection.dart';

class Frames {
  final TcpConnection _tcpConnection = TcpConnection();

  // Frame type constants in hex
  static const String QUERY_FRAME = "51"; // 'Q' in hex
  static const String DATA_FRAME = "44"; // 'D' in hex

  // Common method for processing hex data

  // CRC16-Modbus calculation
  int calculateCRC16Modbus(List<int> data) {
    int crc = 0xFFFF;
    for (int byte in data) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x0001) != 0) {
          crc = (crc >> 1) ^ 0xA001;
        } else {
          crc >>= 1;
        }
      }
    }
    return crc;
  }

  String getCRC16ModbusHex(List<int> data) {
    int crc = calculateCRC16Modbus(data);
    return crc.toRadixString(16).padLeft(4, '0').toUpperCase();
  }

  // Helper method for configuration fields
  void sendQueryField({
    required String fieldId, // Unique field ID
    required String fc, // Function Code
    String value = "", // Field value if any
  }) {
    List<int> frameData = [
      0x3C, // SOF
      int.parse(fc, radix: 16), // FC
      int.parse(fieldId, radix: 16), // FF (field ID)
      0x44, // FT (Query Frame)
    ];

    String crc = getCRC16ModbusHex(frameData);
    frameData.addAll(hexToBytes(crc)); // Add CRC bytes

    if (_tcpConnection.isConnected) {
      _tcpConnection.sendHexCommand(frameData);
    } else {
      print("TCP not connected!");
    }
    print("Sending configuration for field $fieldId with CRC: $crc");
  }

  List<int> hexToBytes(String hex) {
    hex = hex.replaceAll(' ', '').replaceAll('0x', '');
    List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      if (i + 2 <= hex.length) {
        String byteString = hex.substring(i, i + 2);
        bytes.add(int.parse(byteString, radix: 16));
      }
    }
    return bytes;
  }

  Future<List<dynamic>> sendAndGetConfigurationSequence({
    required List<Map<String, String>> configs,
    bool isUpdate = false,
    bool isHexData = false,
    int maxAttempts = 1,
    Duration delayBetweenAttempts = const Duration(milliseconds: 150),
  }) async {
    List<dynamic> results = [];

    for (var config in configs) {
      dynamic result;
      bool shouldRetry = true;

      for (int attempt = 0; attempt < maxAttempts && shouldRetry; attempt++) {
        try {
          print(
              "Sending ${isUpdate ? 'update' : 'configuration'} frame attempt ${attempt + 1} for FC: ${config['fc']}, Field: ${config['fieldId']}");

          List<int> frameData = [
            0x3C, // SOF
            int.parse(config['fc']!, radix: 16), // FC
            int.parse(config['fieldId']!, radix: 16), // FF
            isUpdate ? int.parse(DATA_FRAME, radix: 16) : 0x51, // FT
          ];
          if (isUpdate) {
            String value = config['value'] ?? '';
            List<int> valueBytes = value.codeUnits;
            int dataLength = valueBytes.length;

            frameData.add(dataLength);
            frameData.addAll(valueBytes);
          }

          String crc = getCRC16ModbusHex(frameData);
          frameData.addAll(hexToBytes(crc));

          if (_tcpConnection.isConnected) {
            // Convert frameData to hex string for debugging
            String frameHex = frameData
                .map((byte) =>
                    byte.toRadixString(16).padLeft(2, '0').toUpperCase())
                .join(' ');
            print("Sending frame: $frameHex");

            final response = await _tcpConnection.sendHexCommandAndWaitResponse(
              frameData,
              timeout: const Duration(milliseconds: 5),
            );
            if (response['success'] == true) {
              if (response['data'] != null) {
                result = response['data'];
                shouldRetry = false; // Stop retrying as we received valid data
                print(
                    'Received data for FC: ${config['fc']}, Field: ${config['fieldId']}: $result'); // Log the result to the console
              } else {
                // If no data is received but success is true, try fetching it separately
                print("No data received, attempting to fetch...");
                shouldRetry = result == null;
              }
            } else if (response['reserved'] == true) {
              result = null;
              shouldRetry = false;
              print(
                  "Frame reserved for FC: ${config['fc']}, Field: ${config['fieldId']}");
              break;
            }
          }

          if (shouldRetry && attempt < maxAttempts - 1) {
            await Future.delayed(delayBetweenAttempts);
          }
        } catch (e) {
          print("Attempt ${attempt + 1} failed: $e");
          if (attempt < maxAttempts - 1) {
            await Future.delayed(delayBetweenAttempts);
          }
        }
      }
      results.add(result);
      if (shouldRetry) {
        print(
            "Failed to ${isUpdate ? 'update' : 'send'} configuration after $maxAttempts attempts");
      }
    }
    return results;
  }
}
