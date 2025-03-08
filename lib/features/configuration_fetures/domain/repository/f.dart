//
// ignore_for_file: slash_for_doc_comments, constant_identifier_names

/**================================================================================================
 *?                                     Constants for FUNCTION FRAME   
 *================================================================================================**/
const String FIELD_SSID = "00";
const String FIELD_PASSWORD = "00";
const String FIELD_MAC = "00";

// MQTT FUNCTION fRAME
const String ALL_MQTT = "00";

// analog FUNCTION FRAME
const String V_ANALOGMIN = "01";
const String V_ANALOGMAX = "02";

// jSON FUNCTION FRAME
const String JSON_STATUS = "01";
const String JSON_NAME = "02";
const String JSON_RTU = "00";
const String JSON_TCP = "00";

// Calibrate FUNCTION FRAME
const String CALIBRATE_LOW = "01";
const String CALIBRAT_HIGH = "02";

// INFO FUNCTION FRAME
const String INFO = "00";

// OTA FUNCTION FRAME
const String OTA = "00";

// RTC FUNCTION FRAME
const String RTC = "00";

// TCP FUNCTION FRAME
const String TCP = "00";

// RTC SUB FUNCTION FRAME
const String DSSEMIRTC1 = "01";
const String DSSEMIRTC2 = "02";
const String DSSEMIRTC3 = "03";
const String DSSEMIRTC4 = "04";
const String DSSEMIRTC5 = "05";
const String DSSEMIRTC6 = "06";
const String DSSEMIRTC7 = "07";
const String DSSEMIRTC8 = "08";
const String DSSEMIRTC9 = "09";
const String DSSEMIRTC10 = "0A";

/**================================================================================================
 *?                                   Constants for FUNCTION FRAME   
 *================================================================================================**/
const String FC_SSID = "01";
const String FC_PASSWORD = "02";
const String FC_MAC = "03";

// MQTT DATA
const String FC_USERNAME = "04";
const String FC_MQTTPASSEORD = "05";
const String FC_SERVER = "06";
const String FC_PORT = "07";
const String FC_CLIENDID = "08";
const String FC_PUBLIC = "09";
const String FC_SUBSCRIBE = "0A";
const String FC_QOS = "0B";
const String FC_FRAMEINTERVAL = "0C";

// ANALOG FUNCTION CODE
const String FC_V_MIN_MAX = "0D";
const String FC_mA_MIN_MAX_1 = "0E";
const String FC_mA_MIN_MAX_2 = "0F";

// jSON FUNCTION CODE

const String FC0_10STATUS = "10";
const String FC0_10NAME = "10";

const String FC4_20CH1STATUS = "11";
const String FC4_20CH1NAME = "11";

const String FC4_20CH2STATUS = "12";
const String FC4_20CH2NAME = "12";

const String FC_RELAY1STATUS = "13";
const String FC_RELAY1NAME = "13";

const String FC_RELAY2STATUS = "14";
const String FC_RELAY2NAME = "14";

const String FC_INPUTCH1STATUS = "15";
const String FC_INPUTCH1NAME = "15";

const String FC_INPUTCH2STATUS = "16";
const String FC_INPUTCH2NAME = "16";

const String FC_RTU_STATUS = "17";

const String FC_TCP_STATUS = "18";

// calibrate FUNCTION CODE
const String FC_CALIBRATE_LOW_HIGH = "2B";
const String FC_CALIBRATE_CH1_LOW_HIGH = "2C";
const String FC_CALIBRATE_CH2_LOW_HIGH = "2D";

// INFO FUNCTION CODE
const String FC_INFO_RTC_SERVER = "19";
const String FC_INFO_DEVICE_ID = "1A";
const String FC_INFO_FV = "1B";

//OTA CONFIGURATION
const String FC_OTA_API_KEY = "25"; // 37 in hex
const String FC_OTA_EMAIL = "26"; // 38 in hex
const String FC_OTA_PASSWORD = "27"; // 39 in hex
const String FC_OTA_BUCKET_ID = "28"; // 40 in hex
const String FC_OTA_FW_PATH = "29"; // 41 in hex
const String FC_OTA_STATUS = "2A"; // 42 in hex

// RTC FUNCTION CODE

const String FC_RTC_BAUDRATE = "2E"; // 46 in hex
const String FC_RTC_DATA_LENGTH = "2F"; // 47 in hex
const String FC_RTC_STOP_BIT = "30"; // 48 in hex
const String FC_RTC_PARITY_BIT = "31"; // 49 in hex
const String FC_RTC_SLAVE_COUNT = "32"; // 50 in hex

const String FC_RTC_ENDIANNESS = "33"; // 51 in hex
const String FC_RTC_NAME = "34"; // 52 in hex
const String FC_RTC_ADDRESS = "35"; // 53 in hex
const String FC_RTC_SIZE = "36"; // 54 in hex

// TCP FUNCTION CODE
const String FC_TCP_SERVER_IP = "1C";
const String FC_TCP_CLIENT = "1D";
const String FC_TCP_PORT = "1E";
const String FC_TCP_SLAVE_ID = "1F";
const String FC_TCP_REGISTER_COUNT = "20";
const String FC_TCP_ENDIANNESS = "21";

// ...add other FCs as needed
