import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/ble_provider.dart';

class BlePage extends StatelessWidget {
  const BlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Bluetooth Connection")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Scan for Bluetooth devices", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await bleProvider.startScan(context); // Pass the BuildContext
                },
                child: bleProvider.isLoading ? const  CircularProgressIndicator() : const Text("Start Scan"),
              ),
              const SizedBox(height: 20),
              // Display the filtered devices
              if (bleProvider.filteredDevices.isNotEmpty) ...[
                Text("Filtered Devices:", style: Theme.of(context).textTheme.titleMedium),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bleProvider.filteredDevices.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(bleProvider.filteredDevices[index].platformName),
                      subtitle: Text("ID: ${bleProvider.filteredDevices[index].remoteId}"),
                      trailing: bleProvider.isConnected ? 
                        const Icon(Icons.check, color: Colors.green) : 
                        ElevatedButton(
                          onPressed: () {
                            bleProvider.connectToDevice(bleProvider.filteredDevices[index]);
                          },
                          child: const Text("Connect"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        ),
                      onTap: () {
                        bleProvider.connectToDevice(bleProvider.filteredDevices[index]);
                      },
                    );
                  },
                ),
              ] else ...[
                const Text("No devices found. Click on reset on your device."),
              ],
              if (bleProvider.isError) ...[
                const Text("Error connecting to device", style: TextStyle(color: Colors.red)),
              ],
              if (bleProvider.isConnecting) ...[
                const Text("Connecting...", style: TextStyle(color: Colors.orange)),
              ],
              // Display received TRNG data
              if (bleProvider.isConnected && bleProvider.receivedData != null) ...[
                Text("Received Data: ${bleProvider.receivedData}"), // Removed 'const'
              ],
            ],
          ),
        ),
      ),
      // Persistent footer
      bottomNavigationBar: Container(
        color: Colors.blue[100], // Change color as needed
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bleProvider.isConnected ? "Connected to Bluetooth" : "Disconnected from Bluetooth",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              bleProvider.receivedData != null ? "Receiving TRNG Numbers: ${bleProvider.receivedData}" : "No TRNG Numbers Received",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}







// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'dart:async';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';

// class BlePage extends StatefulWidget {
//   const BlePage({super.key});
//   @override
//   _BlePageState createState() => _BlePageState();
// }

// class _BlePageState extends State<BlePage> {
//   FlutterBluePlus flutterBlue = FlutterBluePlus();
//   List<BluetoothDevice> filteredDevices = []; // List to hold filtered devices
//   bool isLoading = false; // Add a loading state variable
//   bool isConnected = false; // Add this line to define isConnected
//   bool isError = false;
//   bool isConnecting = false;
//   String? receivedData; // Add this line to hold received data

//   void checkBluetoothStatus() async {
//     var adapterState = await FlutterBluePlus.adapterState.first;
//     if (adapterState != BluetoothAdapterState.on) {
//       // Display a warning message in the UI
//       showDialog(
//           context: context,
//           builder: (BuildContext context) {
//               return AlertDialog(
//                   title: Text("Bluetooth Disabled"),
//                   content: Text("Please enable Bluetooth to scan for devices."),
//                   actions: [
//                       TextButton(
//                           child: Text("Enable Bluetooth"),
//                           onPressed: () {
//                               FlutterBluePlus.turnOn(); // Attempt to enable Bluetooth
//                               Navigator.of(context).pop(); // Close the dialog
//                           },
//                       ),
//                       TextButton(
//                           child: Text("Cancel"),
//                           onPressed: () {
//                               Navigator.of(context).pop(); // Close the dialog
//                           },
//                       ),
//                   ],
//               );
//           },
//       );
//       return; // Don't proceed with the scan if Bluetooth is off
//     }
//     print("Bluetooth is on.");
//   }

//   void _startScan() async {
//     setState(() {
//       isLoading = true; // Set loading to true when starting the scan
//     });

//     checkBluetoothStatus();

//     // Check if location services are enabled
//     if (!(await Permission.location.serviceStatus.isEnabled)) {
//       print("Location services are disabled. Please enable them to scan for Bluetooth devices.");
//       return; // Don't proceed with the scan if location services are off
//     }

//     if (await Permission.bluetoothScan.request().isGranted &&
//         await Permission.bluetoothConnect.request().isGranted &&
//         await Permission.location.request().isGranted) {

//       var status = await Permission.locationWhenInUse.status;
//       if (!await Permission.locationWhenInUse.serviceStatus.isEnabled) {
//         print("Location services are disabled.");
//         return;
//       }

//       try {
//         await FlutterBluePlus.startScan(timeout: Duration(seconds: 10)); // Increased scan duration
//         print("Scan started successfully");

//         // Listen to the scanning results
//         FlutterBluePlus.scanResults.listen((results) {
//           filteredDevices.clear(); // Clear the previous results
//           if (results.isEmpty) {
//             print('No Bluetooth devices found.');
//           } else {
//             for (var result in results) {
//               // Check if the device name starts with "emolio"
//               if (result.device.platformName.startsWith("emolio")) {
//                 filteredDevices.add(result.device); // Add to the filtered list
//                 print('Found Bluetooth device! Name: ${result.device.platformName}, RSSI: ${result.rssi}, ID: ${result.device.remoteId}');
//               }
//             }
//             setState(() {}); // Update the UI
//           }
//         }, onError: (error) {
//           print("Error in scan results: $error");
//         });

//         // Optional: Stop scanning as needed
//         await Future.delayed(Duration(seconds: 10)); // Match the scan duration
//         await FlutterBluePlus.stopScan();
//         print("Scan stopped successfully");
//       } catch (error) {
//         print("Error during scan: $error");
//       } finally {
//         setState(() {
//             isLoading = false; // Set loading to false after scan completes
//         });
//       }
//     } else {
//       print("Permissions not granted");
//     }
//   }

//   void _connectToDevice(BluetoothDevice device) async {
//     setState(() {
//       isConnecting = true; // Set connecting state
//       isError = false; 
//     });

//     try {
//       await device.connect();
//       print("Connected to ${device.platformName}");
//       setState(() {
//         isConnected = true; // Set isConnected to true
//         isConnecting = false; // Reset connecting state
//       });
//       // In _connectToDevice function:
//       List<BluetoothService> services = await device.discoverServices();
//       for (BluetoothService service in services) {
//         print("Service UUID: ${service.uuid}");
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           print("Characteristic UUID: ${characteristic.uuid}, Properties: ${characteristic.properties}");
          
//           if (characteristic.uuid.toString() == "1235") {
//             // Enable notifications if supported
//             if (characteristic.properties.notify || characteristic.properties.indicate) {
//               await characteristic.setNotifyValue(true);
//               print("Notifications enabled for characteristic: ${characteristic.uuid}");
              
//               // Subscribe to notifications
//               characteristic.value.listen((data) {
//               if (data.isEmpty) {
//                 print("Received empty data");
//               } else {
//                 String receivedData = String.fromCharCodes(data);
//                 setState(() {
//                   this.receivedData = receivedData; // Update receivedData with the incoming data
//                 });
//                 print("Received data: $receivedData"); // Debug print
//               }
//             }, onError: (error) {
//               print("Error while receiving data: $error");
//             });
//             } else {
//               print("Characteristic does not support notifications.");
//             }
//           }
//         }
//       }


//       // // Discover services
//       // List<BluetoothService> services = await device.discoverServices();
//       // services.forEach((service) {
//       //   if (service.uuid.toString() == "abcd")  {
//       //     var characteristic = service.characteristics.firstWhere((c) => c.uuid.toString() == "1235");

//       //     // Check if the characteristic supports notifications
//       //     if (characteristic.properties.notify || characteristic.properties.indicate) {
//       //         characteristic.setNotifyValue(true);
//       //         print("Notifications enabled for characteristic: ${characteristic.uuid.toString()}");
//       //     } else {
//       //         print("Characteristic does not support notifications."); // Add this line
//       //         // Handle the case where notifications are not supported
//       //     }
//       //     // Subscribe to notifications
        
//       //     characteristic.lastValueStream.listen((data) {
//       //       print("data from esp32");
//       //       print(data);
//       //       // Handle incoming data here
//       //       String receivedData = String.fromCharCodes(data);
//       //       setState(() {
//       //         this.receivedData = receivedData; // Update receivedData with the incoming data
//       //       });
//       //       print("Received data: $receivedData"); // Debug print
//       //     });
//       //   }
//       // });

//       // Call enableNotifications for each characteristic
//       for (BluetoothService service in services) {
//         for (BluetoothCharacteristic characteristic in service.characteristics) {
//           await enableNotifications(characteristic);
//         }
//       }

//     } catch (error) {
//       print("Error connecting to device: $error");
//       setState(() {
//         isError = true; // Set error state
//         isConnecting = false; // Reset connecting state
//       });
//     }
//   }

//   Future<void> enableNotifications(BluetoothCharacteristic characteristic) async { // Mark the function as async
//     if (characteristic.properties.notify || characteristic.properties.indicate) {
//         await characteristic.setNotifyValue(true);
//         print("Notifications enabled for characteristic: ${characteristic.uuid.toString()}");
//     } else {
//         print("Notifications not supported for characteristic: ${characteristic.uuid.toString()}");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text("Scan for Bluetooth devices", style: Theme.of(context).textTheme.titleLarge),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _startScan,
//               child: isLoading ? CircularProgressIndicator() : Text("Start Scan"), // Show loading indicator
//             ),
//             const SizedBox(height: 20),
//             // Display the filtered devices
//             if (filteredDevices.isNotEmpty) ...[
//               Text("Filtered Devices:", style: Theme.of(context).textTheme.titleMedium),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemCount: filteredDevices.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(filteredDevices[index].platformName),
//                     subtitle: Text("ID: ${filteredDevices[index].remoteId}"),
//                     trailing: ElevatedButton(
//                       onPressed: () => _connectToDevice(filteredDevices[index]),
//                       child: isConnected ? Text("Connected") : (isConnecting ? CircularProgressIndicator() : Text("Connect")),// Show loading indicator
//                       style: ButtonStyle(
//                         backgroundColor: isConnected ? MaterialStateProperty.all(Colors.green) : 
//                                        isError ? MaterialStateProperty.all(Colors.red) : 
//                                        MaterialStateProperty.all(Colors.blue), // Change color based on state
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//             const SizedBox(height: 20),
//             // Display the received data from ESP32
//             if (isConnected) ...[
//               Text("Received from ESP32: $receivedData", style: Theme.of(context).textTheme.titleMedium), // Display received data
//             ],
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
