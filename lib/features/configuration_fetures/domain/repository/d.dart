import 'dart:developer';

import 'package:semicalibration/features/configuration_fetures/domain/bloc/frames/frames.dart';
import 'package:semicalibration/features/configuration_fetures/domain/repository/f.dart';
import 'package:semicalibration/features/configuration_fetures/presentation/controllers/present_controllers.dart';

class D {
  static final D _instance = D._internal();
  factory D() {
    return _instance;
  }
  D._internal();
  static D get instance => _instance;

  Frames frame = Frames();
  final PresentControllers _controllers = PresentControllers();

  /**============================================
   *               changeConfig Method
   *=============================================**///

  Future<void> handleDropdownChange({
    required String fieldConfig,
    required String fieldId,
    required String? status,
    bool invertValues = false,
    String enableValue = "1",
    String disableValue = "0",
  }) async {
    try {
      final configs = <Map<String, String>>[];

      if (status == null) {
        configs.add({
          'fc': fieldConfig,
          'fieldId': fieldId,
          'value': '?',
        });

        final response = await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: false,
        );

        if (response != null && response.isNotEmpty) {
          log('Current Status for $fieldId: $response');
        }
      } else {
        final value = status == "Enable"
            ? (invertValues ? disableValue : enableValue)
            : (invertValues ? enableValue : disableValue);

        configs.add({
          'fc': fieldConfig,
          'fieldId': fieldId,
          'value': value,
        });

        await frame.sendAndGetConfigurationSequence(
          configs: configs,
          isUpdate: true,
        );

        log('Status updated for $fieldId to: $status (value: $value)');
      }
    } catch (e) {
      log('Error in handleDropdownChange for $fieldId: ${e.toString()}');
    }
  }


  Future<String?> handleQueryResponse({
    required String fieldConfig,
    required String fieldId,
  }) async {
    try {
      final configs = <Map<String, String>>[
        {
          'fc': fieldConfig,
          'fieldId': fieldId,
          'value': '?',
        }
      ];

      final response = await frame.sendAndGetConfigurationSequence(
        configs: configs,
        isUpdate: false,
      );

      if (response != null && response.isNotEmpty) {
        print("Query raw response: $response");
        String dropdownState = response == "30" ? "Enable" : "Disable";
        log('Query response for $fieldId: $response (State: $dropdownState)');
        return dropdownState;
      }
      return null;
    } catch (e) {
      log('Error in query response for $fieldId: ${e.toString()}');
      return null;
    }
  }

  Future<void> changeOTAStatus(bool isIt, {String? otaStatus}) async {
    await handleDropdownChange(
      fieldConfig: FC_OTA_STATUS,
      fieldId: OTA,
      status: isIt ? otaStatus : null,
      invertValues: true,
    );
  }

  //JSON Dropdown

  Future<void> changeJsonStatus(bool isIt, {String? jsonStatus}) async {
    await handleDropdownChange(
      fieldConfig: FC0_10STATUS,
      fieldId: JSON_STATUS,
      status: isIt ? jsonStatus : null,
    );
  }

  Future<void> changeJsonCh1Status(bool isIt, {String? jsonCh1Status}) async {
    await handleDropdownChange(
      fieldConfig: FC4_20CH1STATUS,
      fieldId: JSON_STATUS,
      status: isIt ? jsonCh1Status : null,
    );
  }

  Future<void> changeJsonCh2Status(bool isIt, {String? jsonCh2Status}) async {
    await handleDropdownChange(
      fieldConfig: FC4_20CH2STATUS,
      fieldId: JSON_STATUS,
      status: isIt ? jsonCh2Status : null,
    );
  }

  Future<void> changeJsonRelaych1Status(bool isIt,
      {String? jsonRelayCh1Status}) async {
    await handleDropdownChange(
      fieldConfig: FC4_20CH2STATUS,
      fieldId: JSON_STATUS,
      status: isIt ? jsonRelayCh1Status : null,
    );
  }

  Future<void> changeJsonRelaych2Status(bool isIt,
      {String? jsonRelayCh1Status}) async {
    await handleDropdownChange(
      fieldConfig: FC4_20CH2STATUS,
      fieldId: JSON_STATUS,
      status: isIt ? jsonRelayCh1Status : null,
    );
  }

  Future<void> changeJsonInputch1Status(bool isIt,
      {String? jsonInputCh1Status}) async {
    await handleDropdownChange(
      fieldConfig: FC4_20CH2STATUS,
      fieldId: JSON_STATUS,
      status: isIt ? jsonInputCh1Status : null,
    );
  }

  Future<void> changeJsonInputch2Status(bool isIt,
      {String? jsonInputCh2Status}) async {
    await handleDropdownChange(
      fieldConfig: FC4_20CH2STATUS,
      fieldId: JSON_STATUS,
      status: isIt ? jsonInputCh2Status : null,
    );
  }
  //  RTU Dropdown

  // STATUS SETUP
  Future<String?> queryJsonStatus() async {
    return await handleQueryResponse(
      fieldConfig: FC0_10STATUS,
      fieldId: JSON_STATUS,
    );
  }

  Future<String?> queryJsonCh1Status() async {
    return await handleQueryResponse(
      fieldConfig: FC4_20CH1STATUS,
      fieldId: JSON_STATUS,
    );
  }

  Future<String?> queryJsonCh2Status() async {
    return await handleQueryResponse(
      fieldConfig: FC4_20CH2STATUS,
      fieldId: JSON_STATUS,
    );
  }

  Future<String?> queryOTAStatus() async {
    return await handleQueryResponse(
      fieldConfig: FC_OTA_STATUS,
      fieldId: OTA,
    );
  }
}
