import 'dart:developer';
import 'dart:async'; // Add this import

import 'package:flutter/material.dart';
import 'package:semicalibration/features/configuration_fetures/domain/bloc/frames/frames.dart';
import 'package:semicalibration/features/configuration_fetures/domain/repository/f.dart';
import 'package:semicalibration/features/configuration_fetures/domain/repository/tcp_connection.dart';

class PresentControllers {
  final TcpConnection _tcpConnection = TcpConnection();
  final Frames _frame = Frames();

  // WiFi Configuration Controllers
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();
  final macAddressController = TextEditingController();

  // MQTT Configuration Controllers
  final mqttUsernameController = TextEditingController();
  final mqttPasswordController = TextEditingController();
  final serverController = TextEditingController();
  final portController = TextEditingController();
  final clientIdController = TextEditingController();
  final publishTopicController = TextEditingController();
  final keepAliveController = TextEditingController();
  final qosController = TextEditingController();
  final subscribeTopicController = TextEditingController();

  // Analog Configuration Controllers
  final v10MinController = TextEditingController();
  final v10MaxController = TextEditingController();
  final ma420Ch1MinController = TextEditingController();
  final ma420Ch1MaxController = TextEditingController();
  final ma420Ch2MinController = TextEditingController();
  final ma420Ch2MaxController = TextEditingController();

  // Calibrate Configuration Controllers
  final v10CalibLowController = TextEditingController();
  final v10CalibHighController = TextEditingController();
  final ma420Ch1CalibLowController = TextEditingController();
  final ma420Ch1CalibHighController = TextEditingController();
  final ma420Ch2CalibLowController = TextEditingController();
  final ma420Ch2CalibHighController = TextEditingController();

  // RTU Configuration Controllers
  final baudrateController = TextEditingController();
  final dataLengthController = TextEditingController();
  final stopBitController = TextEditingController();
  final parityBitController = TextEditingController();
  final slaveCountController = TextEditingController();
  // final endinnessRtuController = TextEditingController();

  // Slave Configuration Controllers

  final slaveEndiannessController = TextEditingController();
  final slaveNameController = TextEditingController();
  final slaveAddrController = TextEditingController();
  final slaveSizeController = TextEditingController();

  // JSON Configuration Controllers
  final v10NameController = TextEditingController();
  final ma420Ch1NameController = TextEditingController();
  final ma420Ch2NameController = TextEditingController();
  final relay1NameController = TextEditingController();
  final relay2NameController = TextEditingController();
  final inputCh1NameController = TextEditingController();
  final inputCh2NameController = TextEditingController();

  final v10StatusController = TextEditingController();
  final ma420Ch1StatusController = TextEditingController();
  final ma420Ch2StatusController = TextEditingController();
  final relay1StatusController = TextEditingController();
  final relay2StatusController = TextEditingController();
  final inputCh1StatusController = TextEditingController();
  final inputCh2StatusController = TextEditingController();

  // Info Configuration Controllers
  final rtcServerController = TextEditingController();
  final deviceTypeController = TextEditingController();
  final firmwareVersionController = TextEditingController();

  // TCP Configuration Controllers
  final serverIpController = TextEditingController();
  final clientIpController = TextEditingController();
  final tcpPortController = TextEditingController();
  final slaveIdController = TextEditingController();
  final registerCountController = TextEditingController();

  // OTA Configuration Controllers
  final apiKeyController = TextEditingController();
  final emailController = TextEditingController();
  final otaPasswordController = TextEditingController();
  final bucketIdController = TextEditingController();
  final fwPathController = TextEditingController();

  final receiveMessageController = ValueNotifier(<List<String>>[]);

  // Add these maps to store slave input controllers
  final Map<String, TextEditingController> _slaveNameControllers = {};
  final Map<String, TextEditingController> _slaveAddrControllers = {};
  final Map<String, TextEditingController> _slaveSizeControllers = {};

  // Add these getter methods
  TextEditingController getSlaveNameController(int slaveIndex, int inputIndex) {
    String key = 'slave${slaveIndex}_name$inputIndex';
    _slaveNameControllers[key] ??= TextEditingController();
    return _slaveNameControllers[key]!;
  }

  TextEditingController getSlaveAddrController(int slaveIndex, int inputIndex) {
    String key = 'slave${slaveIndex}_addr$inputIndex';
    _slaveAddrControllers[key] ??= TextEditingController();
    return _slaveAddrControllers[key]!;
  }

  TextEditingController getSlaveSizeController(int slaveIndex, int inputIndex) {
    String key = 'slave${slaveIndex}_size$inputIndex';
    _slaveSizeControllers[key] ??= TextEditingController();
    return _slaveSizeControllers[key]!;
  }

   TextEditingController getSlaveEndiannessController(int slaveIndex, int inputIndex) {
    String key = 'slave${slaveIndex}_name$inputIndex';
    _slaveNameControllers[key] ??= TextEditingController();
    return _slaveNameControllers[key]!;
  }


  // Modify handleSlaveFieldCompletion method
  void handleSlaveFieldCompletion(
      int slaveIndex, int inputIndex, String type, String value) {
    String ff = inputIndex < 9 ? '0${inputIndex + 1}' : '0A';
    String fc;
    Map<String, String> configData;

    // Log the initial values
    print('==== Slave Field Completion ====');
    print('Slave Index: $slaveIndex');
    print('Input Index: $inputIndex');
    print('Type: $type');
    print('Value: $value');
    print('Field ID (ff): $ff');

    switch (type) {
      case 'name':
        fc = FC_RTC_NAME;
        configData = {
          'fc': fc,
          'fieldId': ff,
          'value': getSlaveNameController(slaveIndex, inputIndex).text,
        };
        print(
            'Name Controller Value: ${getSlaveNameController(slaveIndex, inputIndex).text}');
        break;
      case 'address':
        fc = FC_RTC_ADDRESS;
        configData = {
          'fc': fc,
          'fieldId': ff,
          'value': getSlaveAddrController(slaveIndex, inputIndex).text,
        };
        print(
            'Address Controller Value: ${getSlaveAddrController(slaveIndex, inputIndex).text}');
        break;
      case 'size':
        fc = FC_RTC_SIZE;
        configData = {
          'fc': fc,
          'fieldId': ff,
          'value': getSlaveSizeController(slaveIndex, inputIndex).text,
        };
        print(
            'Size Controller Value: ${getSlaveSizeController(slaveIndex, inputIndex).text}');
        break;
      default:
        print('Unknown type: $type');
        return;
    }

    print('Config Data: $configData');

    _frame.sendAndGetConfigurationSequence(
      configs: [configData],
      isUpdate: true,
    ).then((results) {
      print('Response Results: $results');
      if (results.isNotEmpty && results[0] != null) {
        switch (type) {
          case 'name':
            getSlaveNameController(slaveIndex, inputIndex).text = results[0];
            print('Updated Name Value: ${results[0]}');
            break;
          case 'address':
            getSlaveAddrController(slaveIndex, inputIndex).text = results[0];
            print('Updated Address Value: ${results[0]}');
            break;
          case 'size':
            getSlaveSizeController(slaveIndex, inputIndex).text = results[0];
            print('Updated Size Value: ${results[0]}');
            break;
        }
      }
    });
  }

  // Add method to fetch slave data for a specific slave
  Future<void> fetchSlaveData(int slaveIndex) async {
    print('\n==== Fetching Slave Data ====');
    print('Slave Index: $slaveIndex');

    final ffValues = [
      DSSEMIRTC1,
      DSSEMIRTC2,
      DSSEMIRTC3,
      DSSEMIRTC4,
      DSSEMIRTC5,
      DSSEMIRTC6,
      DSSEMIRTC7,
      DSSEMIRTC8,
      DSSEMIRTC9,
      DSSEMIRTC10
    ];

    for (var i = 0; i < ffValues.length; i++) {
      print('\nFetching data for input $i (FF: ${ffValues[i]})');

      final configs = [
        {
          'fc': FC_RTC_NAME,
          'fieldId': ffValues[i],
          'value': '',
        },
        {
          'fc': FC_RTC_ADDRESS,
          'fieldId': ffValues[i],
          'value': '',
        },
        {
          'fc': FC_RTC_SIZE,
          'fieldId': ffValues[i],
          'value': '',
        },
      ];

      print('Sending configs: $configs');
      final results = await _frame.sendAndGetConfigurationSequence(
        configs: configs,
        isUpdate: false,
      );
      print('Received results: $results');

      if (results.length >= 3) {
        getSlaveNameController(slaveIndex, i).text = results[0] ?? '';
        getSlaveAddrController(slaveIndex, i).text = results[1] ?? '';
        getSlaveSizeController(slaveIndex, i).text = results[2] ?? '';

        print('Updated controllers for input $i:');
        print('  Name: ${getSlaveNameController(slaveIndex, i).text}');
        print('  Address: ${getSlaveAddrController(slaveIndex, i).text}');
        print('  Size: ${getSlaveSizeController(slaveIndex, i).text}');
      } else {
        print('Warning: Insufficient results received for input $i');
      }
    }
  }

  PresentControllers() {
    _tcpConnection.messageController.stream.listen((message) {
      receiveMessageController.value = [
        ...receiveMessageController.value,
        [message]
      ];
      log('Message on line 85 : $message');
    });

    _tcpConnection.dataController.stream.listen((data) {
      // Handle received data based on FC and FF
      if (data['fc'] == 1) {
        // FC_WIFI
        switch (data['ff']) {
          case 0:
            ssidController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 2) {
        // FC_PASSWORD
        switch (data['ff']) {
          case 0:
            passwordController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 3) {
        // FC_MAC
        switch (data['ff']) {
          case 0:
            macAddressController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x04) {
        // FC_MQTT_USERNAME
        switch (data['ff']) {
          case 0x00:
            mqttUsernameController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x05) {
        switch (data['ff']) {
          case 0x00:
            mqttPasswordController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x06) {
        switch (data['ff']) {
          case 0x00:
            serverController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x07) {
        switch (data['ff']) {
          case 0x00:
            portController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x08) {
        switch (data['ff']) {
          case 0x00:
            clientIdController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x09) {
        switch (data['ff']) {
          case 0x00:
            publishTopicController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x0a) {
        switch (data['ff']) {
          case 0x00:
            subscribeTopicController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x0b) {
        switch (data['ff']) {
          case 0x00:
            qosController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x0c) {
        switch (data['ff']) {
          case 0x00:
            keepAliveController.text = data['data'];
            break;
        }
        //! FC_MQTT_E END
      } else if (data['fc'] == 0x0D) {
        //ANALOG
        switch (data['ff']) {
          case 0x01:
            v10MinController.text = data['data'];
            break;
          case 0x02:
            v10MaxController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x0E) {
        switch (data['ff']) {
          case 0x01:
            ma420Ch1MinController.text = data['data'];
            break;
          case 0x02:
            ma420Ch1MaxController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x0F) {
        switch (data['ff']) {
          case 0x01:
            ma420Ch2MinController.text = data['data'];
            break;
          case 0x02:
            ma420Ch2MaxController.text = data['data'];
            break;
        }
        //! ANALOG END
      } else if (data['fc'] == 0x10) {
        print('Processing FC 0x10 data: $data'); // Debug log
        switch (data['ff']) {
          case 0x01:
            v10StatusController.text = data['data'];
            print('Updated v10 status: ${data['data']}');
            break;
          case 0x02:
            v10NameController.text = data['data'];
            print('Updated v10 name: ${data['data']}');
            break;
        }
      } else if (data['fc'] == 0x11) {
        print('Processing FC 0x11 data: $data'); // Debug log
        switch (data['ff']) {
          case 0x01:
            ma420Ch1StatusController.text = data['data'];
            print('Updated ma420Ch1 status: ${data['data']}');
            break;
          case 0x02:
            ma420Ch1NameController.text = data['data'];
            print('Updated ma420Ch1 name: ${data['data']}');
            break;
        }
      } else if (data['fc'] == 0x12) {
        print('Processing FC 0x12 data: $data'); // Debug log
        switch (data['ff']) {
          case 0x01:
            ma420Ch2StatusController.text = data['data'];
            print('Updated ma420Ch2 status: ${data['data']}');
            break;
          case 0x02:
            ma420Ch2NameController.text = data['data'];
            print('Updated ma420Ch2 name: ${data['data']}');
            break;
        }
      } else if (data['fc'] == 0x13) {
        print('Processing FC 0x13 data: $data'); // Debug log
        switch (data['ff']) {
          case 0x01:
            relay1StatusController.text = data['data'];
            print('Updated relay1 status: ${data['data']}');
            break;
          case 0x02:
            relay1NameController.text = data['data'];
            print('Updated relay1 name: ${data['data']}');
            break;
        }
      } else if (data['fc'] == 0x14) {
        print('Processing FC 0x14 data: $data'); // Debug log
        switch (data['ff']) {
          case 0x01:
            relay2StatusController.text = data['data'];
            print('Updated relay2 status: ${data['data']}');
            break;
          case 0x02:
            relay2NameController.text = data['data'];
            print('Updated relay2 name: ${data['data']}');
            break;
        }
      } else if (data['fc'] == 0x15) {
        print('Processing FC 0x15 data: $data'); // Debug log
        switch (data['ff']) {
          case 0x01:
            inputCh1StatusController.text = data['data'];
            print('Updated inputCh1 status: ${data['data']}');
            break;
          case 0x02:
            inputCh1NameController.text = data['data'];
            print('Updated inputCh1 name: ${data['data']}');
            break;
        }
      } else if (data['fc'] == 0x16) {
        print('Processing FC 0x16 data: $data'); // Debug log
        switch (data['ff']) {
          case 0x01:
            inputCh2StatusController.text = data['data'];
            print('Updated inputCh2 status: ${data['data']}');
            break;
          case 0x02:
            inputCh2NameController.text = data['data'];
            print('Updated inputCh2 name: ${data['data']}');
            break;
        }
      }
      //! JSON END
      else if (data['fc'] == 0x2B) {
        // calibrate Frames
        switch (data['ff']) {
          case 0x01:
            v10CalibLowController.text = data['data'];
            break;
          case 0x02:
            v10CalibHighController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x2C) {
        switch (data['ff']) {
          case 0x01:
            ma420Ch1CalibLowController.text = data['data'];
            break;
          case 0x02:
            ma420Ch1CalibHighController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x2D) {
        switch (data['ff']) {
          case 0x01:
            ma420Ch2CalibLowController.text = data['data'];
            break;
          case 0x02:
            ma420Ch2CalibHighController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x19) {
        //! INFO
        switch (data['ff']) {
          case 0x00:
            rtcServerController.text = data['data'];
            break;
        }
        switch (data['ff']) {
          case 0x00:
            deviceTypeController.text = data['data'];
            break;
        }
        switch (data['ff']) {
          case 0x00:
            firmwareVersionController.text = data['data'];
            break;
        }
      }
      //! CALIBRATE END
      else if (data['fc'] == 0x25) {
        // OTA Start
        switch (data['ff']) {
          case 0x00:
            apiKeyController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x26) {
        switch (data['ff']) {
          case 0x00:
            emailController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x27) {
        switch (data['ff']) {
          case 0x00:
            otaPasswordController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x28) {
        switch (data['ff']) {
          case 0x00:
            bucketIdController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x29) {
        switch (data['ff']) {
          case 0x00:
            fwPathController.text = data['data'];
            break;
        }
      }
      //! OTA END
      else if (data['fc'] == 0x2E) {
        // RTC start
        switch (data['ff']) {
          case 0x00:
            baudrateController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x2F) {
        switch (data['ff']) {
          case 0x00:
            dataLengthController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x30) {
        switch (data['ff']) {
          case 0x00:
            stopBitController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x31) {
        switch (data['ff']) {
          case 0x00:
            parityBitController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x32) {
        switch (data['ff']) {
          case 0x00:
            slaveCountController.text = data['data'];
            break;
        }
      }
      //! RTC END

      //! TCP START
      else if (data['fc'] == 0x1C) {
        switch (data['ff']) {
          case 0x00:
            serverIpController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x1D) {
        // Fixed condition from 'FF' to 'fc'
        switch (data['ff']) {
          case 0x00:
            clientIpController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x1E) {
        // Fixed condition from 'ff' to 'fc'
        switch (data['ff']) {
          case 0x00:
            tcpPortController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x1F) {
        // Fixed condition from 'ff' to 'fc'
        switch (data['ff']) {
          case 0x00:
            slaveIdController.text = data['data'];
            break;
        }
      } else if (data['fc'] == 0x20) {
        // Fixed condition from 'ff' to 'fc'
        switch (data['ff']) {
          case 0x00:
            registerCountController.text = data['data'];
            break;
        }
      }
    });
  }

  void handleFieldCompletion(String fieldLabel, String value) {
    print("Handling field completion for: '$fieldLabel' with value: '$value'");

    switch (fieldLabel) {
      case 'SSID:':
        log("SSID complete with value: $value");
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_SSID,
              'fieldId': FIELD_SSID,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;

      case 'Password:':
        log("Password complete with value: $value");
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_PASSWORD,
              'fieldId': FIELD_PASSWORD,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;

      case 'MAC ADDRESS: ':
        log("MAC complete with value: $value");
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_MAC,
              'fieldId': FIELD_MAC,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;

      // MQTT Configuration
      case 'Username:':
        log("Username complete with value: $value");
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_USERNAME,
              'fieldId': ALL_MQTT,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Password:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_MQTTPASSEORD,
              'fieldId': ALL_MQTT,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Server:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_SERVER,
              'fieldId': ALL_MQTT,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Port:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_PORT,
              'fieldId': ALL_MQTT,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Client ID:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_CLIENDID,
              'fieldId': ALL_MQTT,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Publish Topic:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_PUBLIC,
              'fieldId': ALL_MQTT,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Subscribe Topic:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_SUBSCRIBE,
              'fieldId': ALL_MQTT,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'QoS:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_QOS,
              'fieldId': ALL_MQTT,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Keep Alive:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_FRAMEINTERVAL,
              'fieldId': ALL_MQTT,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      // Analog Configuration
      case '0-10V Min:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_V_MIN_MAX,
              'fieldId': V_ANALOGMIN,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case '0-10V Max:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_V_MIN_MAX,
              'fieldId': V_ANALOGMAX,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case '4-20mA CH1 Min:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_mA_MIN_MAX_1,
              'fieldId': V_ANALOGMIN,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case '4-20mA CH1 Max:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_mA_MIN_MAX_1,
              'fieldId': V_ANALOGMAX,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case '4-20mA CH1 Min:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_mA_MIN_MAX_2,
              'fieldId': V_ANALOGMIN,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case '4-20mA CH1 Max:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_mA_MIN_MAX_2,
              'fieldId': V_ANALOGMAX,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;

      case '0-10V Calib Low:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_CALIBRATE_LOW_HIGH,
              'fieldId': CALIBRATE_LOW,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;

      case '0-10V Calib High:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_CALIBRATE_LOW_HIGH,
              'fieldId': CALIBRAT_HIGH,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;

      case '4-20mA CH1 Calib Low:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_CALIBRATE_CH1_LOW_HIGH,
              'fieldId': CALIBRATE_LOW,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;

      case '4-20mA CH1 Calib High:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_CALIBRATE_CH1_LOW_HIGH,
              'fieldId': CALIBRAT_HIGH,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;

      case '4-20mA CH2 Calib Low:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_CALIBRATE_CH2_LOW_HIGH,
              'fieldId': CALIBRATE_LOW,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case '4-20mA CH2 Calib High:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_CALIBRATE_CH2_LOW_HIGH,
              'fieldId': CALIBRAT_HIGH,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
       case '4-20mA CH2 Calib Min:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_CALIBRATE_CH2_LOW_HIGH,
              'fieldId': CALIBRATE_LOW,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
       case '4-20mA CH2 Calib High:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_CALIBRATE_CH2_LOW_HIGH,
              'fieldId': CALIBRAT_HIGH,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
       case 'RTC Server:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_INFO_RTC_SERVER,
              'fieldId': INFO,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Device Type:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_INFO_DEVICE_ID,
              'fieldId': INFO,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Firameware Version:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_INFO_FV,
              'fieldId': INFO,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Baudrate:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_RTC_BAUDRATE,
              'fieldId': RTC,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Data Length:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_RTC_DATA_LENGTH,
              'fieldId': RTC,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Stop Bit:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_RTC_STOP_BIT,
              'fieldId': RTC,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Parity Bit:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_RTC_PARITY_BIT,
              'fieldId': RTC,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Slave Count:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_RTC_SLAVE_COUNT,
              'fieldId': RTC,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      // JSON UPDATE
      case '1-10V Name:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC0_10NAME,
              'fieldId': JSON_NAME,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case '4-20mA CH1 Name:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC4_20CH1NAME,
              'fieldId': JSON_NAME,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case '4-20mA CH2 Name:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC4_20CH2NAME,
              'fieldId': JSON_NAME,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Relay1 Name:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_RELAY1NAME,
              'fieldId': JSON_NAME,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Reply2 Name:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_RELAY2NAME,
              'fieldId': JSON_NAME,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Input CH1 Name:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_INPUTCH1NAME,
              'fieldId': JSON_NAME,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Input CH2 Name:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_INPUTCH2NAME,
              'fieldId': JSON_NAME,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;

        // OTA CONFIGURATION
      case 'API Key:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_OTA_API_KEY,
              'fieldId': OTA,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Email:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_OTA_EMAIL,
              'fieldId': OTA,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'OTA Password:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_OTA_PASSWORD,
              'fieldId': OTA,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      // case 'Bucket ID:':
      //   _frame.sendAndGetConfigurationSequence(
      //     configs: [
      //       {
      //         'fc': FC_OTA_BUCKET_ID,
      //         'fieldId': OTA,
      //         'value': value,
      //       }
      //     ],
      //     isUpdate: true,
      //   );
      //   break;
      // case 'FW Path:':
      //   _frame.sendAndGetConfigurationSequence(
      //     configs: [
      //       {
      //         'fc': FC_OTA_FW_PATH,
      //         'fieldId': OTA,
      //         'value': value,
      //       }
      //     ],
      //     isUpdate: true,
      //   );
      //   break;

      // TCP CONFIGURATION
      case 'Server IP:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_TCP_SERVER_IP,
              'fieldId': TCP,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Client IP:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_TCP_CLIENT,
              'fieldId': TCP,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;   
      case 'TCP Port:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_TCP_PORT,
              'fieldId': TCP,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Slave ID:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_TCP_SLAVE_ID,
              'fieldId': TCP,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      case 'Register Count:':
        _frame.sendAndGetConfigurationSequence(
          configs: [
            {
              'fc': FC_TCP_REGISTER_COUNT,
              'fieldId': TCP,
              'value': value,
            }
          ],
          isUpdate: true,
        );
        break;
      default:
        log("Unhandled field: $fieldLabel");
        break;
    }
  }

  void dispose() {
    // Dispose all controllers
    ssidController.dispose();
    passwordController.dispose();
    macAddressController.dispose();
    mqttUsernameController.dispose();
    mqttPasswordController.dispose();
    serverController.dispose();
    portController.dispose();
    clientIdController.dispose();
    publishTopicController.dispose();
    keepAliveController.dispose();
    qosController.dispose();
    subscribeTopicController.dispose();
    v10MinController.dispose();
    v10MaxController.dispose();
    ma420Ch1MinController.dispose();
    ma420Ch1MaxController.dispose();
    ma420Ch2MinController.dispose();
    ma420Ch2MaxController.dispose();

    // Calibrate Configuration Controllers
    v10CalibHighController.dispose();
    v10CalibLowController.dispose();
    ma420Ch1CalibLowController.dispose();
    ma420Ch1CalibHighController.dispose();
    ma420Ch2CalibLowController.dispose();
    ma420Ch2CalibHighController.dispose();

    // INFO
    rtcServerController.dispose();
    deviceTypeController.dispose();
    firmwareVersionController.dispose();

    // OTA
    apiKeyController.dispose();
    emailController.dispose();
    otaPasswordController.dispose();
    bucketIdController.dispose();
    fwPathController.dispose();

    // Dispose slave input controllers
    _slaveNameControllers.values.forEach((controller) => controller.dispose());
    _slaveAddrControllers.values.forEach((controller) => controller.dispose());
    _slaveSizeControllers.values.forEach((controller) => controller.dispose());
  }
}
