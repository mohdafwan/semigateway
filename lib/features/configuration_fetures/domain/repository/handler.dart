import 'dart:developer';
import 'dart:ffi';

import 'package:semicalibration/features/configuration_fetures/domain/bloc/frames/frames.dart';
import 'package:semicalibration/features/configuration_fetures/presentation/controllers/present_controllers.dart';

import 'f.dart';

class Handler {
  static final Handler _instance = Handler._internal();
  factory Handler() {
    return _instance;
  }
  Handler._internal();
  static Handler get instance => _instance;

  Frames frame = Frames();
  final PresentControllers _controllers = PresentControllers();

  Future<void> mqttConfigurationHandler(bool isIt) async {
    try {
      final configs = [
        {
          'fc': FC_USERNAME,
          'fieldId': ALL_MQTT,
          'value': _controllers.ssidController.text,
        },
        {
          'fc': FC_MQTTPASSEORD,
          'fieldId': ALL_MQTT,
          'value': _controllers.passwordController.text,
        },
        {
          'fc': FC_SERVER,
          'fieldId': ALL_MQTT,
          'value': _controllers.macAddressController.text,
        },
        {
          'fc': FC_PORT,
          'fieldId': ALL_MQTT,
          'value': _controllers.macAddressController.text,
        },
        {
          'fc': FC_CLIENDID,
          'fieldId': ALL_MQTT,
          'value': _controllers.macAddressController.text,
        },
        {
          'fc': FC_PUBLIC,
          'fieldId': ALL_MQTT,
          'value': _controllers.macAddressController.text,
        },
        {
          'fc': FC_SUBSCRIBE,
          'fieldId': ALL_MQTT,
          'value': _controllers.macAddressController.text,
        },
        {
          'fc': FC_QOS,
          'fieldId': ALL_MQTT,
          'value': _controllers.macAddressController.text,
        },
        {
          'fc': FC_FRAMEINTERVAL,
          'fieldId': ALL_MQTT,
          'value': _controllers.macAddressController.text,
        },
      ];

      if (isIt == false) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: isIt,
        );

        log("WiFi Configuration Results: ${results.toList()}");
      } else if (isIt == true) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: isIt,
        );
        log("WiFi Else Configuration Results: $results");
      } else {
        log("WiFi Configuration Results: $isIt");
      }
    } catch (e) {
      print("Error sending WiFi configuration: $e");
    }
  }

  Future<void> sendWiFiConfiguration(bool isIt) async {
    try {
      final configs = [
        {
          'fc': FC_SSID,
          'fieldId': FIELD_SSID,
          'value': _controllers.ssidController.text,
        },
        {
          'fc': FC_PASSWORD,
          'fieldId': FIELD_PASSWORD,
          'value': _controllers.passwordController.text,
        },
        {
          'fc': FC_MAC,
          'fieldId': FIELD_MAC,
          'value': _controllers.macAddressController.text,
        },
      ];

      if (isIt == true) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: isIt,
        );
        if (results.isNotEmpty && results[0] != null) {
          for (var i = 0; i < configs.length; i++) {
            if (results[i] == null || results[i].isEmpty) {
              for (int attempt = 0; attempt < 4; attempt++) {
                final retryConfig = [configs[i]];
                final retryResults =
                    await frame.sendAndGetConfigurationSequence(
                  configs: retryConfig,
                  isUpdate: isIt,
                );
                if (retryResults.isNotEmpty && retryResults[0] != null) {
                  results[i] = retryResults[0];
                  break;
                }
                log("Attempt ${attempt + 1} failed for config ${configs[i]['fc']}");
              }
            }

            switch (configs[i]['fc']) {
              case FIELD_SSID:
                _controllers.ssidController.text = results[i] ?? 'No Value';
                break;
              case FIELD_PASSWORD:
                _controllers.passwordController.text = results[i] ?? 'No Value';
                break;
              case FIELD_MAC:
                _controllers.macAddressController.text =
                    results[i] ?? 'No Value';
                break;
            }
          }
        }

        log("WiFi Configuration Results: $results");
      } else if (isIt == false) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: isIt,
        );
        log("WiFi Else Configuration Results: $results");
      } else {
        log("WiFi Configuration Results: $isIt");
      }
    } catch (e) {
      print("Error sending WiFi configuration: $e");
    }
  }

  Future<void> analogConfigurationHandler(bool isIt) async {
    try {
      final configs = [
        {
          'fc': FC_V_MIN_MAX,
          'fieldId': V_ANALOGMIN,
          'value': _controllers.v10MinController.text,
        },
        {
          'fc': FC_V_MIN_MAX,
          'fieldId': V_ANALOGMAX,
          'value': _controllers.v10MaxController.text,
        },
        {
          'fc': FC_mA_MIN_MAX_1,
          'fieldId': V_ANALOGMIN,
          'value': _controllers.ma420Ch1MinController.text,
        },
        {
          'fc': FC_mA_MIN_MAX_1,
          'fieldId': V_ANALOGMAX,
          'value': _controllers.ma420Ch1MaxController.text,
        },
        {
          'fc': FC_mA_MIN_MAX_2,
          'fieldId': V_ANALOGMIN,
          'value': _controllers.ma420Ch2MinController.text,
        },
        {
          'fc': FC_mA_MIN_MAX_2,
          'fieldId': V_ANALOGMAX,
          'value': _controllers.ma420Ch2MaxController.text,
        },
      ];

      if (isIt == true) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: isIt,
        );

        if (results.isNotEmpty && results[0] != null) {
          for (var i = 0; i < configs.length; i++) {
            if (results[i] == null || results[i].isEmpty) {
              for (int attempt = 0; attempt < 4; attempt++) {
                final retryConfig = [configs[i]];
                final retryResults =
                    await frame.sendAndGetConfigurationSequence(
                  configs: retryConfig,
                  isUpdate: isIt,
                );
                if (retryResults.isNotEmpty && retryResults[0] != null) {
                  results[i] = retryResults[0];
                  break;
                }
                log("Attempt ${attempt + 1} failed for config ${configs[i]['fc']}");
              }
            }

            switch (configs[i]['fieldId']) {
              case V_ANALOGMIN:
                _controllers.v10MinController.text = results[i] ?? 'No Value';
                break;
              case V_ANALOGMAX:
                _controllers.v10MaxController.text = results[i] ?? 'No Value';
                break;
              //4-20mA CH1
              case V_ANALOGMIN:
                _controllers.ma420Ch1MinController.text =
                    results[i] ?? 'No Value';
                break;
              case V_ANALOGMAX:
                _controllers.ma420Ch1MaxController.text =
                    results[i] ?? 'No Value';
                break;
              //4-20mA CH2
              case V_ANALOGMIN:
                _controllers.ma420Ch2MinController.text =
                    results[i] ?? 'No Value';
                break;
              case V_ANALOGMAX:
                _controllers.ma420Ch2MaxController.text =
                    results[i] ?? 'No Value';
                break;
            }
          }
        }

        log("Analog Configuration Results: ${results.toList()}");
      } else if (isIt == false) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: isIt,
        );
        log("Analog Else Configuration Results: $results");
      } else {
        log("Analog Configuration Results: $isIt");
      }
    } catch (e) {
      print("Error sending Analog configuration: $e");
    }
  }

  Future<void> jsonConfigurationHandler(bool isIt) async {
    try {
      print('\n==== JSON Configuration Handler ====');
      print('Is Update: $isIt');

      final configs = [
        {
          'fc': FC0_10NAME,
          'fieldId': JSON_NAME,
          'value': _controllers.v10NameController.text,
        },
        {
          'fc': FC4_20CH1NAME,
          'fieldId': JSON_NAME,
          'value': _controllers.ma420Ch1NameController.text,
        },
        {
          'fc': FC4_20CH2NAME,
          'fieldId': JSON_NAME,
          'value': _controllers.ma420Ch2NameController.text,
        },
        {
          'fc': FC_RELAY1NAME,
          'fieldId': JSON_NAME,
          'value': _controllers.relay1NameController.text,
        },
        {
          'fc': FC_RELAY2NAME,
          'fieldId': JSON_NAME,
          'value': _controllers.relay2NameController.text,
        },
        {
          'fc': FC_INPUTCH1NAME,
          'fieldId': JSON_NAME,
          'value': _controllers.inputCh1NameController.text,
        },
        {
          'fc': FC_INPUTCH2NAME,
          'fieldId': JSON_NAME,
          'value': _controllers.inputCh2NameController.text,
        },
      ];

      if (isIt) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: true,
        );
        print('JSON Update Results: $results');
      } else {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: false,
        );

        print('Raw JSON Get Results: $results');

        if (results.isNotEmpty) {
          for (var i = 0; i < results.length && i < configs.length; i++) {
            if (results[i] != null) {
              switch (configs[i]['fc']) {
                case FC0_10NAME:
                  _controllers.v10NameController.text = results[i].toString();
                  _controllers.v10StatusController.text = results[i].toString();
                  print('Updated v10 name: ${results[i]}');
                  break;
                case FC4_20CH1NAME:
                  _controllers.ma420Ch1NameController.text =
                      results[i].toString();
                  _controllers.ma420Ch1StatusController.text =
                      results[i].toString();
                  print('Updated ma420Ch1 name: ${results[i]}');
                  break;
                case FC4_20CH2NAME:
                  _controllers.ma420Ch2NameController.text =
                      results[i].toString();
                  _controllers.ma420Ch2StatusController.text =
                      results[i].toString();
                  print('Updated ma420Ch2 name: ${results[i]}');
                  break;
                case FC_RELAY1NAME:
                  _controllers.relay1NameController.text =
                      results[i].toString();
                  _controllers.relay1StatusController.text =
                      results[i].toString();
                  print('Updated relay1 name: ${results[i]}');
                  break;
                case FC_RELAY2NAME:
                  _controllers.relay2NameController.text =
                      results[i].toString();
                  _controllers.relay2StatusController.text =
                      results[i].toString();
                  print('Updated relay2 name: ${results[i]}');
                  break;
                case FC_INPUTCH1NAME:
                  _controllers.inputCh1NameController.text =
                      results[i].toString();
                  _controllers.inputCh1StatusController.text =
                      results[i].toString();
                  print('Updated inputCh1 name: ${results[i]}');
                  break;
                case FC_INPUTCH2NAME:
                  _controllers.inputCh2NameController.text =
                      results[i].toString();
                  _controllers.inputCh2StatusController.text =
                      results[i].toString();
                  print('Updated inputCh2 name: ${results[i]}');
                  break;
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error sending JSON configuration: $e");
      print("Stack trace: ${StackTrace.current}");
    }
  }

  Future<void> calibrateConfigurationHandler(bool isIt) async {
    try {
      final configs = [
        {
          'fc': FC_CALIBRATE_LOW_HIGH,
          'fieldId': CALIBRATE_LOW, // Changed from V_ANALOGMIN
          'value': _controllers.v10CalibLowController.text,
        },
        {
          'fc': FC_CALIBRATE_LOW_HIGH,
          'fieldId': CALIBRAT_HIGH, // Changed from V_ANALOGMAX
          'value': _controllers.v10CalibHighController.text,
        },
        {
          'fc': FC_CALIBRATE_CH1_LOW_HIGH,
          'fieldId': CALIBRATE_LOW,
          'value': _controllers.ma420Ch1CalibLowController.text,
        },
        {
          'fc': FC_CALIBRATE_CH1_LOW_HIGH,
          'fieldId': CALIBRAT_HIGH,
          'value': _controllers.ma420Ch1CalibHighController.text,
        },
        {
          'fc': FC_CALIBRATE_CH2_LOW_HIGH,
          'fieldId': CALIBRATE_LOW,
          'value': _controllers.ma420Ch2CalibLowController.text,
        },
        {
          'fc': FC_CALIBRATE_CH2_LOW_HIGH,
          'fieldId': CALIBRAT_HIGH,
          'value': _controllers.ma420Ch2CalibHighController.text,
        },
      ];

      if (isIt) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: true,
        );

        log("Calibrate Update Results: $results");

        // Add response handling for update case
        if (results.isNotEmpty) {
          for (var i = 0; i < configs.length; i++) {
            switch (configs[i]['fc']) {
              case FC_CALIBRATE_LOW_HIGH:
                if (configs[i]['fieldId'] == CALIBRATE_LOW) {
                  _controllers.v10CalibLowController.text =
                      results[i] ?? 'No Value';
                } else if (configs[i]['fieldId'] == CALIBRAT_HIGH) {
                  _controllers.v10CalibHighController.text =
                      results[i] ?? 'No Value';
                }
                break;

              case FC_CALIBRATE_CH1_LOW_HIGH:
                if (configs[i]['fieldId'] == CALIBRATE_LOW) {
                  _controllers.ma420Ch1CalibLowController.text =
                      results[i] ?? 'No Value';
                } else if (configs[i]['fieldId'] == CALIBRAT_HIGH) {
                  _controllers.ma420Ch1CalibHighController.text =
                      results[i] ?? 'No Value';
                }
                break;

              case FC_CALIBRATE_CH2_LOW_HIGH:
                if (configs[i]['fieldId'] == CALIBRATE_LOW) {
                  _controllers.ma420Ch2CalibLowController.text =
                      results[i] ?? 'No Value';
                } else if (configs[i]['fieldId'] == CALIBRAT_HIGH) {
                  _controllers.ma420Ch2CalibHighController.text =
                      results[i] ?? 'No Value';
                }
                break;
            }
          }
        }

        // Retry logic for failed updates
        if (results.isNotEmpty) {
          for (var i = 0; i < configs.length; i++) {
            if (results[i] == null || results[i].isEmpty) {
              for (int attempt = 0; attempt < 4; attempt++) {
                final retryConfig = [configs[i]];
                final retryResults =
                    await frame.sendAndGetConfigurationSequence(
                  configs: retryConfig,
                  isUpdate: true,
                );
                if (retryResults.isNotEmpty && retryResults[0] != null) {
                  results[i] = retryResults[0];
                  break;
                }
                log("Attempt ${attempt + 1} failed for config ${configs[i]['fc']}");
              }
            }
          }
        }
      } else {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: false,
        );

        if (results.isNotEmpty) {
          for (var i = 0; i < configs.length; i++) {
            switch (configs[i]['fc']) {
              case FC_CALIBRATE_LOW_HIGH:
                if (configs[i]['fieldId'] == CALIBRATE_LOW) {
                  _controllers.v10CalibLowController.text =
                      results[i] ?? 'No Value';
                } else {
                  _controllers.v10CalibHighController.text =
                      results[i] ?? 'No Value';
                }
                break;

              case FC_CALIBRATE_CH1_LOW_HIGH:
                if (configs[i]['fieldId'] == CALIBRATE_LOW) {
                  _controllers.ma420Ch1CalibLowController.text =
                      results[i] ?? 'No Value';
                } else {
                  _controllers.ma420Ch1CalibHighController.text =
                      results[i] ?? 'No Value';
                }
                break;

              case FC_CALIBRATE_CH2_LOW_HIGH:
                if (configs[i]['fieldId'] == CALIBRATE_LOW) {
                  _controllers.ma420Ch2CalibLowController.text =
                      results[i] ?? 'No Value';
                } else {
                  _controllers.ma420Ch2CalibHighController.text =
                      results[i] ?? 'No Value';
                }
                break;
            }
          }
        }
        log("Calibrate Get Results: $results");
      }
    } catch (e) {
      print("Error in calibrate configuration: $e");
    }
  }

  Future<void> infoConfigurationHandler(bool isIt) async {
    try {
      final configs = [
        {
          'fc': FC_INFO_RTC_SERVER,
          'fieldId': INFO,
          'value': _controllers.rtcServerController.text,
        },
        {
          'fc': FC_INFO_DEVICE_ID,
          'fieldId': INFO,
          'value': _controllers.deviceTypeController.text,
        },
        {
          'fc': FC_INFO_FV,
          'fieldId': INFO,
          'value': _controllers.firmwareVersionController.text,
        },
      ];

      if (isIt) {
      } else {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: false,
        );

        if (results.isNotEmpty) {
          for (var i = 0; i < configs.length; i++) {
            switch (configs[i]['fc']) {
              case FC_INFO_RTC_SERVER:
                if (configs[i]['fieldId'] == INFO) {
                  _controllers.rtcServerController.text =
                      results[i] ?? 'No Value';
                }
                break;
              case FC_INFO_DEVICE_ID:
                if (configs[i]['fieldId'] == INFO) {
                  _controllers.deviceTypeController.text =
                      results[i] ?? 'No Value';
                }
                break;
              case FC_INFO_FV:
                if (configs[i]['fieldId'] == INFO) {
                  _controllers.firmwareVersionController.text =
                      results[i] ?? 'No Value';
                }
                break;
            }
          }
        }
        log("Calibrate Get Results: $results");
      }
    } catch (e) {
      print("Error in calibrate configuration: $e");
    }
  }

  Future<void> otaConfigurationHandler(bool isIt, {String? otaStatus}) async {
    try {
      final configs = [
        {
          'fc': FC_OTA_API_KEY,
          'fieldId': OTA,
          'value': _controllers.apiKeyController.text,
        },
        {
          'fc': FC_OTA_EMAIL,
          'fieldId': OTA,
          'value': _controllers.emailController.text,
        },
        {
          'fc': FC_OTA_PASSWORD,
          'fieldId': OTA,
          'value': _controllers.otaPasswordController.text,
        },
        {
          'fc': FC_OTA_BUCKET_ID,
          'fieldId': OTA,
          'value': _controllers.bucketIdController.text,
        },
        {
          'fc': FC_OTA_FW_PATH,
          'fieldId': OTA,
          'value': _controllers.fwPathController.text,
        },
      ];

      if (isIt) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: true,
        );
        log("OTA Update Results: $results");
      } else {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: false,
        );

        log("Raw OTA Get Results: $results");

        if (results.isNotEmpty) {
          for (var i = 0; i < results.length && i < configs.length; i++) {
            if (results[i] != null) {
              switch (configs[i]['fc']) {
                case FC_OTA_API_KEY:
                  _controllers.apiKeyController.text = results[i].toString();
                  break;
                case FC_OTA_EMAIL:
                  _controllers.emailController.text = results[i].toString();
                  break;
                case FC_OTA_PASSWORD:
                  _controllers.otaPasswordController.text =
                      results[i].toString();
                  break;
                case FC_OTA_BUCKET_ID:
                  _controllers.bucketIdController.text = results[i].toString();
                  break;
                case FC_OTA_FW_PATH:
                  _controllers.fwPathController.text = results[i].toString();
                  break;
              }
            }
          }
        }
      }
    } catch (e, stackTrace) {
      print("Error in OTA configuration: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> rtuConfigurationHandler(bool isIt,
      {Function? onSlaveCountChanged}) async {
    try {
      print('\n==== RTU Configuration Handler ====');
      print('Is Update: $isIt');

      final configs = [
        {
          'fc': FC_RTC_BAUDRATE,
          'fieldId': RTC,
          'value': _controllers.baudrateController.text,
        },
        {
          'fc': FC_RTC_DATA_LENGTH,
          'fieldId': RTC,
          'value': _controllers.dataLengthController.text,
        },
        {
          'fc': FC_RTC_STOP_BIT,
          'fieldId': RTC,
          'value': _controllers.stopBitController.text,
        },
        {
          'fc': FC_RTC_PARITY_BIT,
          'fieldId': RTC,
          'value': _controllers.parityBitController.text,
        },
        {
          'fc': FC_RTC_SLAVE_COUNT,
          'fieldId': RTC,
          'value': _controllers.slaveCountController.text,
        },
      ];

      print('Sending configs: $configs');

      if (isIt) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: true,
        );
        // Handle update case
        print('Update case not implemented');
      } else {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: false,
        );
        print('Received results: $results');

        if (results.isNotEmpty) {
          for (var i = 0; i < configs.length; i++) {
            print('\nProcessing result $i:');
            print('Config: ${configs[i]}');
            print('Result: ${results[i]}');

            switch (configs[i]['fc']) {
              case FC_RTC_BAUDRATE:
                if (configs[i]['fieldId'] == RTC) {
                  _controllers.baudrateController.text =
                      results[i] ?? 'No Value';
                  print(
                      'Updated baudrate: ${_controllers.baudrateController.text}');
                }
                break;
              case FC_RTC_DATA_LENGTH:
                if (configs[i]['fieldId'] == RTC) {
                  _controllers.dataLengthController.text =
                      results[i] ?? 'No Value';
                  print(
                      'Updated data length: ${_controllers.dataLengthController.text}');
                }
                break;
              case FC_RTC_STOP_BIT:
                if (configs[i]['fieldId'] == RTC) {
                  _controllers.stopBitController.text =
                      results[i] ?? 'No Value';
                  print(
                      'Updated stop bit: ${_controllers.stopBitController.text}');
                }
                break;
              case FC_RTC_PARITY_BIT:
                if (configs[i]['fieldId'] == RTC) {
                  _controllers.parityBitController.text =
                      results[i] ?? 'No Value';
                  print(
                      'Updated parity bit: ${_controllers.parityBitController.text}');
                }
                break;
              case FC_RTC_SLAVE_COUNT:
                if (configs[i]['fieldId'] == RTC) {
                  _controllers.slaveCountController.text =
                      results[i] ?? 'No Value';
                  print(
                      'Updated slave count: ${_controllers.slaveCountController.text}');

                  int slaveCount =
                      int.tryParse(_controllers.slaveCountController.text) ?? 0;
                  print('\nFetching data for $slaveCount slaves');

                  for (int slaveIndex = 0;
                      slaveIndex < slaveCount;
                      slaveIndex++) {
                    print('\nFetching data for slave $slaveIndex');
                    await _controllers.fetchSlaveData(slaveIndex);
                    
                    // Add this: Fetch Endianness for each slave
                    await slaveEndiannessConfigurationHandler(slaveIndex, slaveIndex, false);
                  }

                  if (onSlaveCountChanged != null) {
                    print('Triggering slave count changed callback');
                    onSlaveCountChanged();
                  }
                }
                break;
            }
          }
        }
      }
    } catch (e) {
      print("Error in RTU configuration: $e");
      print("Stack trace: ${StackTrace.current}");
    }
  }

  Future<void> tcpxConfigurationHandler(bool isIt, {String? otaStatus}) async {
    try {
      final configs = [
        {
          'fc': FC_TCP_SERVER_IP,
          'fieldId': TCP,
          'value': _controllers.serverIpController.text,
        },
        {
          'fc': FC_TCP_CLIENT,
          'fieldId': TCP,
          'value': _controllers.clientIpController.text,
        },
        {
          'fc': FC_TCP_PORT,
          'fieldId': TCP,
          'value': _controllers.tcpPortController.text,
        },
        {
          'fc': FC_TCP_SLAVE_ID,
          'fieldId': TCP,
          'value': _controllers.slaveIdController.text,
        },
        {
          'fc': FC_TCP_REGISTER_COUNT,
          'fieldId': TCP,
          'value': _controllers.registerCountController.text,
        },
      ];

      if (isIt) {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: true,
        );
        log("OTA Update Results: $results");
      } else {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: false,
        );
        if (results.isNotEmpty) {
          for (var i = 0; i < configs.length; i++) {
            if (results.isNotEmpty) {
              for (var i = 0; i < configs.length; i++) {
                switch (configs[i]['fc']) {
                  case FC_TCP_SERVER_IP:
                    if (configs[i]['fieldId'] == TCP) {
                      _controllers.serverIpController.text =
                          results[i] ?? 'No Value';
                    }
                    break;
                  case FC_TCP_CLIENT:
                    if (configs[i]['fieldId'] == TCP) {
                      _controllers.clientIpController.text =
                          results[i] ?? 'No Value';
                    }
                    break;
                  case FC_TCP_PORT:
                    if (configs[i]['fieldId'] == TCP) {
                      _controllers.tcpPortController.text =
                          results[i] ?? 'No Value';
                    }
                    break;
                  case FC_TCP_SLAVE_ID:
                    if (configs[i]['fieldId'] == TCP) {
                      _controllers.slaveIdController.text =
                          results[i] ?? 'No Value';
                    }
                    break;
                  case FC_TCP_REGISTER_COUNT:
                    if (configs[i]['fieldId'] == TCP) {
                      _controllers.registerCountController.text =
                          results[i] ?? 'No Value';
                    }
                    break;
                }
              }
            }
          }
        }
      }
    } catch (e, stackTrace) {
      print("Error in OTA configuration: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> finalConfigurationHandler(bool isIt) async {
    try {
      final configs = [
        {
          'fc': FC_INFO_RTC_SERVER,
          'fieldId': INFO,
          'value': _controllers.rtcServerController.text,
        },
        {
          'fc': FC_INFO_DEVICE_ID,
          'fieldId': INFO,
          'value': _controllers.deviceTypeController.text,
        },
        {
          'fc': FC_INFO_FV,
          'fieldId': INFO,
          'value': _controllers.firmwareVersionController.text,
        },
      ];

      if (isIt) {
      } else {
        final results = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: false,
        );

        if (results.isNotEmpty) {
          for (var i = 0; i < configs.length; i++) {
            switch (configs[i]['fc']) {
              case FC_INFO_RTC_SERVER:
                if (configs[i]['fieldId'] == INFO) {
                  _controllers.rtcServerController.text =
                      results[i] ?? 'No Value';
                }
                break;
              case FC_INFO_DEVICE_ID:
                if (configs[i]['fieldId'] == INFO) {
                  _controllers.deviceTypeController.text =
                      results[i] ?? 'No Value';
                }
                break;
              case FC_INFO_FV:
                if (configs[i]['fieldId'] == INFO) {
                  _controllers.firmwareVersionController.text =
                      results[i] ?? 'No Value';
                }
                break;
            }
          }
        }
        log("Calibrate Get Results: $results");
      }
    } catch (e) {
      print("Error in calibrate configuration: $e");
    }
  }

  Future<void> slaveEndiannessConfigurationHandler(
  int slaveIndex,
  int inputIndex,
  bool isUpdate,
) async {
  try {
    print('\n==== Fetching Endianness for Slave $slaveIndex ====');
    String ff = inputIndex < 9 ? '0${inputIndex + 1}' : '0A';
    
    final configs = [
      {
        'fc': FC_RTC_ENDIANNESS,
        'fieldId': ff,
        'value': _controllers.getSlaveEndiannessController(slaveIndex, inputIndex).text,
      }
    ];

    if (!isUpdate) {
      final results = await frame.sendAndGetConfigurationSequence(
        configs: configs,
        isUpdate: false,
      );
      
      if (results.isNotEmpty && results[0] != null) {
        print('Received endianness value: ${results[0]}');
        
        _controllers.getSlaveEndiannessController(slaveIndex, inputIndex).text = results[0];
        
        _controllers.receiveMessageController.notifyListeners();
      }
    }
  } catch (e) {
    print("Error fetching endianness: $e");
    print("Stack trace: ${StackTrace.current}");
  }
}
}
