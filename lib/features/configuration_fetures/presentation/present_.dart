import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:semicalibration/core/ui/appcolor.dart';
import 'package:semicalibration/core/ui/defaultButtom.dart';
import 'package:semicalibration/features/configuration_fetures/domain/bloc/frames/frames.dart';
import 'package:semicalibration/features/configuration_fetures/domain/repository/d.dart';
import 'package:semicalibration/features/configuration_fetures/domain/repository/f.dart';
import 'package:semicalibration/features/configuration_fetures/domain/repository/handler.dart';
import 'package:semicalibration/features/configuration_fetures/domain/repository/tcp_connection.dart';
import 'package:semicalibration/features/configuration_fetures/presentation/widgets/labeled_dropdown.dart';
import 'controllers/present_controllers.dart';

class PresentScreen extends StatefulWidget {
  const PresentScreen({super.key});

  @override
  State<PresentScreen> createState() => _PresentScreenState();
}

class _PresentScreenState extends State<PresentScreen> {
  Frames frame = Frames();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerRight = ScrollController();
  bool _isDragging = false;
  double _startY = 0;

  String? selectedV10Status = "Disable";
  final List<String> selectedV10StatusItem = ["Disable", "Enable"];
  String? selectedMa420Ch1Status = "Disable";
  final List<String> selectedMa420Ch1StatusItem = ["Disable", "Enable"];
  String? selectedMa420Ch2Status = "Disable";
  final List<String> selectedMa420Ch2StatusItem = ["Disable", "Enable"];
  String? selectedRelay1Status = "Disable";
  final List<String> selectedRelay1StatusItem = ["Disable", "Enable"];
  String? selectedRelay2Status = "Disable";
  final List<String> selectedRelay2StatusItem = ["Disable", "Enable"];
  String? selectedInputCh1Status = "Disable";
  final List<String> selectedInputCh1StatusItem = ["Disable", "Enable"];
  String? selectedInputCh2Status = "Disable";
  final List<String> selectedInputCh2StatusItem = ["Disable", "Enable"];

  String? selectedRTU = "Disable";
  final List<String> rtuTypes = ["Disable", "Enable"];

  String? selectLittle = "Little Endian";
  final List<String> endianness = ["Little Endian", "Big Endian"];

  final PresentControllers _controllers = PresentControllers();
  final TcpConnection _tcpConnection = TcpConnection();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    initializeDropdowns();
    _initConnection();
    _tcpConnection.messageController.stream.listen((message) {
      log(message); // For debugging
    });
  }

 // this is the drop done thing
  void initializeDropdowns() async {
  String? jsonStatus = await D.instance.queryJsonStatus();
  if (jsonStatus != null) {
    setState(() {
      selectedV10Status = jsonStatus;
    });
  }
  
  String? ch1Status = await D.instance.queryJsonCh1Status();
  if (ch1Status != null) {
    setState(() {
      selectedMa420Ch1Status = ch1Status;
    });
  }
  }

  Future<void> _initConnection() async {
    bool connected = await _tcpConnection.connect("192.168.4.1", 23);
    setState(() {
      isConnected = connected;
    });
  }

  @override
  void dispose() {
    _controllers.dispose();
    _scrollController.dispose();
    _scrollControllerRight.dispose();
    _tcpConnection.dispose();
    super.dispose();
  }

  void _handleDrag(PointerMoveEvent event) {
    if (_isDragging) {
      final delta = _startY - event.position.dy;
      _startY = event.position.dy;
      _scrollController.jumpTo(
        (_scrollController.offset + delta).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
      );
    }
  }

  void _handleDragRight(PointerMoveEvent event) {
    if (_isDragging) {
      final delta = _startY - event.position.dy;
      _startY = event.position.dy;
      _scrollControllerRight.jumpTo(
        (_scrollControllerRight.offset + delta).clamp(
          0.0,
          _scrollControllerRight.position.maxScrollExtent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Configuration ${isConnected ? '(Connected)' : '(Disconnected)'}',
              style: TextStyle(
                color: isConnected ? Colors.green : Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
                onPressed: () async {
                  if (isConnected) {
                    await _fetchAllConfigurations();
                  }
                },
                icon: const Icon(Icons.flash_on_outlined)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isConnected ? Icons.link : Icons.link_off),
            onPressed: _initConnection,
          ),
        ],
      ),
      body: isConnected
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: AppColor.primaryColor,
                    child: Listener(
                      onPointerDown: (event) {
                        if (event.buttons == 1) {
                          _isDragging = true;
                          _startY = event.position.dy;
                        }
                      },
                      onPointerUp: (event) {
                        _isDragging = false;
                      },
                      onPointerMove: _handleDrag,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              // Wi-Fi Configuration
                              _buildSectionContainer(
                                'Wi-Fi Configuration',
                                Column(
                                  children: [
                                    _buildFieldRow([
                                      _buildLabeledField(
                                        'SSID:',
                                        null,
                                        _controllers.ssidController,
                                      ),
                                      _buildLabeledField(
                                        'Password:',
                                        null,
                                        _controllers.passwordController,
                                      ),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField(
                                        'MAC ADDRESS: ',
                                        null,
                                        _controllers.macAddressController,
                                      ),
                                      DefaultButton(
                                        title: 'Get WI-Fi',
                                        onPressed: () {
                                          Handler()
                                              .sendWiFiConfiguration(false);
                                        },
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // MQTT Configuration
                              _buildSectionContainer(
                                'MQTT Configuration',
                                Column(
                                  children: [
                                    _buildFieldRow([
                                      _buildLabeledField('Username:', '',
                                          _controllers.mqttUsernameController),
                                      _buildLabeledField('Password:', '',
                                          _controllers.mqttPasswordController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('Server:', '',
                                          _controllers.serverController),
                                      _buildLabeledField('Port:', '',
                                          _controllers.portController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('Client ID:', '',
                                          _controllers.clientIdController),
                                      _buildLabeledField('Publish Topic:', '',
                                          _controllers.publishTopicController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('Keep Alive:', '',
                                          _controllers.keepAliveController),
                                      _buildLabeledField('QoS:', '',
                                          _controllers.qosController),
                                    ]),
                                    const SizedBox(height: 7),
                                    _buildFieldRow([
                                      _buildLabeledField(
                                          'Subscribe Topic:',
                                          '',
                                          _controllers
                                              .subscribeTopicController),
                                      DefaultButton(
                                          title: 'Get MQTT',
                                          onPressed: () {
                                            Handler().mqttConfigurationHandler(
                                                false);
                                          }),
                                    ]),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Analog Configuration
                              _buildSectionContainer(
                                'Analog Configuration',
                                Column(
                                  children: [
                                    _buildFieldRow([
                                      _buildLabeledField('0-10V Min:', '',
                                          _controllers.v10MinController),
                                      _buildLabeledField('0-10V Max:', '',
                                          _controllers.v10MaxController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('4-20mA CH1 Min:', '',
                                          _controllers.ma420Ch1MinController),
                                      _buildLabeledField('4-20mA CH1 Max:', '',
                                          _controllers.ma420Ch1MaxController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('4-20mA CH2 Min', '',
                                          _controllers.ma420Ch2MinController),
                                      _buildLabeledField('4-20mA CH2 Mxn', '',
                                          _controllers.ma420Ch2MaxController),
                                    ]),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: DefaultButton(
                                        title: 'Get Analog',
                                        onPressed: () {
                                          Handler().analogConfigurationHandler(
                                              false);
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Calibrate Configuration
                              _buildSectionContainer(
                                'Calibrate Configuration',
                                Column(
                                  children: [
                                    _buildFieldRow([
                                      _buildLabeledField('0-10V Calib Low:', '',
                                          _controllers.v10CalibLowController),
                                      _buildLabeledField(
                                          '0-10V Calib High:',
                                          '',
                                          _controllers.v10CalibHighController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField(
                                          '4-20mA CH1 Calib Low:',
                                          '',
                                          _controllers
                                              .ma420Ch1CalibLowController),
                                      _buildLabeledField(
                                          '4-20mA CH1 Calib High:',
                                          '',
                                          _controllers
                                              .ma420Ch1CalibHighController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField(
                                          '4-20mA CH2 Calib Min:',
                                          '',
                                          _controllers
                                              .ma420Ch2CalibLowController),
                                      _buildLabeledField(
                                          '4-20mA CH2 Calib Min:',
                                          '',
                                          _controllers
                                              .ma420Ch2CalibHighController),
                                    ]),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: DefaultButton(
                                        title: 'Get Calibrate',
                                        onPressed: () {
                                          Handler.instance
                                              .calibrateConfigurationHandler(
                                            false,
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // RTU Configuration
                              _buildSectionContainer(
                                'RTU Configuration',
                                Column(
                                  children: [
                                    // LabeledDropdown(
                                    //   label: 'RTU Configuration:',
                                    //   value: selectedRTU,
                                    //   items: rtuTypes,
                                    //   onChanged: (String? newValue) {
                                    //     setState(() {
                                    //       selectedRTU = newValue;
                                    //     });
                                    //   },
                                    //   hint: 'Select RTU Type',
                                    // ),
                                    // const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('Baudrate:', '',
                                          _controllers.baudrateController),
                                      _buildLabeledField('Data Length:', '',
                                          _controllers.dataLengthController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('Stop Bit:', '',
                                          _controllers.stopBitController),
                                      _buildLabeledField('Parity Bit:', '',
                                          _controllers.parityBitController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField(
                                        'Slave Count:',
                                        '',
                                        _controllers.slaveCountController,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([]),
                                    // Add slave containers here
                                    ..._buildSlaveContainers(),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: DefaultButton(
                                        title: 'Get RTU',
                                        onPressed: () {
                                          Handler.instance
                                              .rtuConfigurationHandler(
                                            false,
                                            onSlaveCountChanged: () {
                                              setState(() {
                                                // This will trigger rebuild when slave count changes
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: AppColor.primaryColor,
                    child: Listener(
                      onPointerDown: (event) {
                        if (event.buttons == 1) {
                          _isDragging = true;
                          _startY = event.position.dy;
                        }
                      },
                      onPointerUp: (event) {
                        _isDragging = false;
                      },
                      onPointerMove: _handleDragRight,
                      child: SingleChildScrollView(
                        controller: _scrollControllerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              // JSON Configuration
                              _buildSectionContainer(
                                'JSON Configuration',
                                Column(
                                  children: [
                                    _buildFieldRow([
                                      // 10V
                                      LabeledDropdown(
                                        label: '1-10V Status:',
                                        value: selectedV10Status,
                                        items: selectedV10StatusItem,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedV10Status = newValue;
                                          });
                                          D.instance.changeJsonStatus(
                                            true,
                                            jsonStatus: newValue,
                                          );
                                        },
                                        hint: 'Status',
                                      ),
                                      _buildLabeledField('1-10V Name:', '',
                                          _controllers.v10NameController),
                                    ]),
                                    const SizedBox(height: 10),
                                    //4-20mA CH1 Status
                                    _buildFieldRow([
                                      LabeledDropdown(
                                        label: '4-20mA CH1 Status:',
                                        value: selectedMa420Ch1Status,
                                        items: selectedMa420Ch1StatusItem,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedMa420Ch1Status = newValue;
                                          });
                                          D.instance.changeJsonCh1Status(
                                            true,
                                            jsonCh1Status: newValue,
                                          );
                                        },
                                        hint: 'Select RTU Type',
                                      ),
                                      _buildLabeledField(
                                          '4-20mA CH1 Name:',
                                          '',
                                          _controllers.ma420Ch1NameController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      LabeledDropdown(
                                        label: '4-20mA CH2 Status:',
                                        value: selectedMa420Ch2Status,
                                        items: selectedMa420Ch2StatusItem,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedMa420Ch2Status = newValue;
                                          });
                                          D.instance.changeJsonCh2Status(
                                            true,
                                            jsonCh2Status: newValue,
                                          );
                                        },
                                        hint: 'Select RTU Type',
                                      ),
                                      _buildLabeledField(
                                        '4-20mA CH2 Name:',
                                        '',
                                        _controllers.ma420Ch2NameController,
                                      ),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      LabeledDropdown(
                                        label: 'Relay1 Status:',
                                        value: selectedRelay1Status,
                                        items: selectedRelay1StatusItem,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedRelay1Status = newValue;
                                          });
                                          D.instance.changeJsonRelaych1Status(
                                            true,
                                            jsonRelayCh1Status: newValue,
                                          );
                                        },
                                        hint: 'Select RTU Type',
                                      ),
                                      _buildLabeledField('Relay1 Name:', '',
                                          _controllers.relay1NameController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      LabeledDropdown(
                                        label: 'Relay2 Status:',
                                        value: selectedRelay2Status,
                                        items: selectedRelay2StatusItem,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedRelay2Status = newValue;
                                          });
                                          D.instance.changeJsonRelaych2Status(
                                            true,
                                            jsonRelayCh1Status: newValue,
                                          );
                                        },
                                        hint: 'Select RTU Type',
                                      ),
                                      _buildLabeledField('Reply2 Name:', '',
                                          _controllers.relay2NameController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      LabeledDropdown(
                                        label: 'Input CH1 Status:',
                                        value: selectedInputCh1Status,
                                        items: selectedInputCh2StatusItem,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedInputCh1Status = newValue;
                                          });
                                          D.instance.changeJsonInputch1Status(
                                            true,
                                            jsonInputCh1Status: newValue,
                                          );
                                        },
                                        hint: 'Select RTU Type',
                                      ),
                                      _buildLabeledField('Input CH1 Name:', '',
                                          _controllers.inputCh1NameController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      LabeledDropdown(
                                        label: 'Input CH2 Status:',
                                        value: selectedInputCh2Status,
                                        items: selectedInputCh2StatusItem,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedInputCh2Status = newValue;
                                          });
                                          D.instance.changeJsonInputch2Status(
                                            true,
                                            jsonInputCh2Status: newValue,
                                          );
                                        },
                                        hint: 'Select input CH Type',
                                      ),
                                      _buildLabeledField('Input CH2 Name:', '',
                                          _controllers.inputCh2NameController),
                                    ]),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: DefaultButton(
                                            title: 'Get JSON',
                                            onPressed: () {
                                              Handler()
                                                  .jsonConfigurationHandler(
                                                      false);
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Info Configuration
                              _buildSectionContainer(
                                "Info Configuration",
                                Column(
                                  children: [
                                    _buildFieldRow([
                                      _buildLabeledField('RTC Server:', '',
                                          _controllers.rtcServerController),
                                      _buildLabeledField('Device Type:', '',
                                          _controllers.deviceTypeController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField(
                                          'Firameware Version:',
                                          '',
                                          _controllers
                                              .firmwareVersionController),
                                    ]),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: DefaultButton(
                                        title: 'Get Info',
                                        onPressed: () {
                                          Handler.instance
                                              .infoConfigurationHandler(
                                            false,
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildSectionContainer(
                                'OTA Configuration',
                                Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('API Key:', '',
                                          _controllers.apiKeyController),
                                      _buildLabeledField('Email:', '',
                                          _controllers.emailController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('OTA Password:', '',
                                          _controllers.otaPasswordController),
                                      _buildLabeledField('Bucket ID:', '',
                                          _controllers.bucketIdController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('FW Path:', '',
                                          _controllers.fwPathController),
                                      LabeledDropdown(
                                        label: 'OTA Status:',
                                        value: selectedRTU,
                                        items: rtuTypes,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedRTU = newValue;
                                          });
                                          D.instance.changeOTAStatus(
                                            true,
                                            otaStatus: newValue,
                                          );
                                          // Handler.instance
                                          //     .otaConfigurationHandler(
                                          //   true,
                                          //   otaStatus: newValue,
                                          // );
                                        },
                                        hint: 'Select RTU Type',
                                      ),
                                    ]),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: DefaultButton(
                                        title: 'Get Info',
                                        onPressed: () {
                                          Handler.instance
                                              .otaConfigurationHandler(false);
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // TCP Configuration
                              _buildSectionContainer(
                                'TCP Configuration',
                                Column(
                                  children: [
                                    LabeledDropdown(
                                      label: 'TCP Status:',
                                      value: selectedRTU,
                                      items: rtuTypes,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedRTU = newValue;
                                        });
                                      },
                                      hint: 'Status',
                                    ),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('Server IP:', '',
                                          _controllers.serverIpController),
                                      _buildLabeledField('Client IP:', '',
                                          _controllers.clientIpController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('Port:', '',
                                          _controllers.tcpPortController),
                                      _buildLabeledField('Slave ID:', '',
                                          _controllers.slaveIdController),
                                    ]),
                                    const SizedBox(height: 10),
                                    _buildFieldRow([
                                      _buildLabeledField('Register Count:', '',
                                          _controllers.registerCountController),
                                      LabeledDropdown(
                                        label: 'Endianness:',
                                        value: selectLittle,
                                        items: endianness,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectLittle = newValue;
                                          });
                                        },
                                        hint: 'Select RTU Type',
                                      ),
                                    ]),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: DefaultButton(
                                        title: 'Get Info',
                                        onPressed: () {
                                          Handler.instance
                                              .tcpxConfigurationHandler(
                                            false,
                                          );
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              // OTA configuration
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not connected to device'),
                  ElevatedButton(
                    onPressed: _initConnection,
                    child: Text('Connect'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionContainer(String title, Widget content) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: AppColor.secondaryColor,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(color: AppColor.fontColor, fontSize: 17),
            ),
          ),
        ),
        const SizedBox(height: 0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          color: AppColor.secondaryColor,
          child: content,
        ),
      ],
    );
  }

  Widget _buildFieldRow(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }

  Widget _buildLabeledField(
      String label, String? initialValue, TextEditingController? controller,
      {Function(String)? onChanged}) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: label.isEmpty ? 0 : 150, // Increased width for label
            child: Text(
              label,
              style: const TextStyle(
                color: AppColor.fontColor,
                fontSize: 14,
              ),
              softWrap: true, // Allow text to wrap
              maxLines: 2, // Allow up to 2 lines
            ),
          ),
          const SizedBox(width: 0), // Reduced spacing
          SizedBox(
            width: 170, // Adjusted width for input
            height: 25,
            child: TextField(
              controller: controller,
              onEditingComplete: () {
                if (controller?.text.isNotEmpty ?? false) {
                  print(
                      "Field $label completed with value: ${controller?.text}");
                  _controllers.handleFieldCompletion(label, controller!.text);
                }
              },
              onChanged: onChanged, // Add this line to handle immediate changes
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _controllers.handleFieldCompletion(label, value);
                }
              },
              style: const TextStyle(
                color: AppColor.fontColor,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.only(
                  left: 5,
                  right: 5,
                  top: 0,
                  bottom: 10,
                ),
                filled: true,
                fillColor: AppColor.primaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColor.buttonColor,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColor.buttonColor,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColor.buttonColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSlaveContainers() {
    int slaveCount = int.tryParse(_controllers.slaveCountController.text) ?? 0;
    List<Widget> containers = [];

    for (int slaveIndex = 0; slaveIndex < slaveCount; slaveIndex++) {
      containers.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.secondaryColor,
                border: Border.all(color: AppColor.buttonColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColor.buttonColor,
                        child: Text(
                          '${slaveIndex + 1}',
                          style: const TextStyle(
                            color: AppColor.fontColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 120),
                         _buildLabeledField(
                            'Endianness',
                            '',
                            _controllers.getSlaveNameController(
                                slaveIndex, slaveIndex,),
                          ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Headers row
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                   // Space for the index
                      Expanded(
                        flex: 1,
                        child: Container(
                          // color: Colors.red,
                          child: const Center(
                            child: Text(
                              'Name',
                              style: TextStyle(
                                color: AppColor.fontColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          // color: Colors.red,
                          child: const Center(
                            child: Text(
                              'Address',
                              style: TextStyle(
                                color: AppColor.fontColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      Expanded(
                        child: Container(
                          // color: Colors.green,
                          child:const Center(
                            child: Text(
                              'Size',
                              style: TextStyle(
                                color: AppColor.fontColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Generated rows
                  ...List.generate(
                    10,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // const SizedBox(width: 8),
                          _buildLabeledField(
                            '',
                            '',
                            _controllers.getSlaveNameController(
                                slaveIndex, index),
                          ),
                          const SizedBox(width: 8),
                          _buildLabeledField(
                            '',
                            '',
                            _controllers.getSlaveAddrController(
                                slaveIndex, index),
                          ),
                          const SizedBox(width: 8),
                          _buildLabeledField(
                            '',
                            '',
                            _controllers.getSlaveSizeController(
                                slaveIndex, index),
                            onChanged: (value) {
                              _controllers.handleSlaveFieldCompletion(
                                  slaveIndex, index, 'name', value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    }
    return containers;
  }

  Future<void> _fetchAllConfigurations() async {
    // Show loading indicator using showDialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      },
    );

    try {
      // Fetch all configurations in sequence
      await Handler().sendWiFiConfiguration(false);
      await Handler().mqttConfigurationHandler(false);
      await Handler().analogConfigurationHandler(false);
      await Handler().calibrateConfigurationHandler(false);
      await Handler().otaConfigurationHandler(false);
      await Handler().infoConfigurationHandler(false);
      await Handler().jsonConfigurationHandler(false);
      await Handler().tcpxConfigurationHandler(false);

      // Add callback for RTU to trigger UI update
      await Handler().rtuConfigurationHandler(
        false,
        onSlaveCountChanged: () {
          setState(() {
            // This will rebuild the UI when slave count changes
          });
        },
      );

      // Fetch all dropdown statuses
      await D.instance.changeJsonStatus(false);
      await D.instance.changeJsonCh1Status(false);
      await D.instance.changeJsonCh2Status(false);
      await D.instance.changeJsonRelaych1Status(false);
      await D.instance.changeJsonRelaych2Status(false);
      await D.instance.changeJsonInputch1Status(false);
      await D.instance.changeJsonInputch2Status(false);
      await D.instance.changeOTAStatus(false);

      // Final state update to ensure UI reflects all changes
      setState(() {});

      initializeDropdowns();

    } catch (e) {
      print("Error fetching all configurations: $e");
    } finally {
      // Hide loading indicator
      Navigator.pop(context);
    }
  }
}
