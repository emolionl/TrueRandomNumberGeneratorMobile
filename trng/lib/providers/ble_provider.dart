import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class BleProvider with ChangeNotifier {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  List<BluetoothDevice> filteredDevices = [];
  bool isLoading = false;
  bool isConnected = false;
  bool isError = false;
  bool isConnecting = false;
  String? receivedData;
  int _trngValue = -1;
  final logger = Logger();
  int count0 = 0;
  int count1 = 0;
  int totalCount = 0;

  int get trngValue => _trngValue;

  Future<void> checkBluetoothStatus(BuildContext context) async {
    var adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Bluetooth Disabled"),
            content: const Text("Please enable Bluetooth to scan for devices."),
            actions: [
              TextButton(
                child: const Text("Enable Bluetooth"),
                onPressed: () {
                  FlutterBluePlus.turnOn();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return; // Don't proceed with the scan if Bluetooth is off
    }
    //print("Bluetooth is on.");
  }

  Future<void> startScan(BuildContext context) async {
    setLoading(true);
    await checkBluetoothStatus(context);

    if (!(await Permission.location.serviceStatus.isEnabled)) {
      logger.i("Location services are disabled.");
      return;
    }

    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {

      var status = await Permission.locationWhenInUse.status;
      if (!await Permission.locationWhenInUse.serviceStatus.isEnabled) {
        logger.i("Location services are disabled.");
        return;
      }

      try {
        await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
        logger.i("Scan started successfully");

        FlutterBluePlus.scanResults.listen((results) {
          filteredDevices.clear();
          if (results.isEmpty) {
            logger.i('No Bluetooth devices found.');
          } else {
            for (var result in results) {
              if (result.device.platformName.startsWith("emolio")) {
                filteredDevices.add(result.device);
                //print('Found Bluetooth device! Name: ${result.device.platformName}, RSSI: ${result.rssi}, ID: ${result.device.remoteId}');
              }
            }
            notifyListeners(); // Notify listeners to update UI
          }
        });

        await Future.delayed(Duration(seconds: 10));
        await FlutterBluePlus.stopScan();
        logger.i("Scan stopped successfully");
      } catch (error) {
        logger.e("Error during scan: $error", error: "Error during scan: $error", stackTrace: StackTrace.current);
      } finally {
        setLoading(false);
      }
    } else {
      logger.i("Permissions not granted");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    setConnecting(true);
    isError = false;

    try {
      await device.connect();
      //print("Connected to ${device.platformName}");
      isConnected = true;
      setConnecting(false);
      
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == "1235") { // Use your characteristic UUID
            if (characteristic.properties.notify || characteristic.properties.indicate) {
              await characteristic.setNotifyValue(true);
              characteristic.value.listen((data) {
                if (data.isEmpty) {
                  logger.i("Received empty data");
                } else {
                  receivedData = String.fromCharCodes(data);
                  //logger.i("receivedData: $receivedData");
                  int? intValue = int.tryParse(receivedData ?? '3'); // Use null-aware operator
                  //logger.i("intValue: $intValue");
                  if (intValue != null) {
                    if (intValue == 0) {
                      count0++;
                      //logger.i('count0 incremented: $count0'); // Debug print
                    } else {
                      count1++;
                      //logger.i('count1 incremented: $count1'); // Debug print
                    }
                    totalCount++;
                  } else if(intValue == 3){
                    logger.e("receivedData is: $intValue");
                  }
                  
                  //updateReceivedData(receivedData);
                  notifyListeners();
                }
              });
            }
          }
        }
      }
    } catch (error) {
      logger.e("Error connecting to device: $error");
      isError = true;
      setConnecting(false);
    }
  }

  Future<int> getTrngData() async {
    // Implement the logic to get TRNG data from ESP32
    int trngData = 0; // Replace with actual data fetching logic
    return trngData;
  }

  Future<void> fetchTrngData() async {
    int trngData = await getTrngData();
    _trngValue = trngData;
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  void setConnecting(bool connecting) {
    isConnecting = connecting;
    notifyListeners();
  }

  void resetCounts() {
        count0 = 0;
        count1 = 0;
        totalCount = 0;
    }
}
