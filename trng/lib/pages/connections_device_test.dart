import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/ble_provider.dart';

class ConnectionDeviceTest extends StatefulWidget {
  const ConnectionDeviceTest({super.key});

  @override
  State<ConnectionDeviceTest> createState() => _ConnectionDeviceTestState();
}

class _ConnectionDeviceTestState extends State<ConnectionDeviceTest> {
  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Testing connection from device"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Check Bluetooth connection and data reception
              if (bleProvider.isConnected) ...[
                if (bleProvider.receivedData != null) ...[
                  Row(
                    children: [
                      Text("Received Data: ${bleProvider.receivedData}"),
                      const SizedBox(width: 4),
                      const Icon(Icons.check, color: Colors.green),
                      const SizedBox(height: 4), // Spacing
                    ],
                  ),
                  // New Row added
                  const Row(
                    children: [
                      Text(
                        'Depending on what you send from the device, it should appear here above.', // Replace with your desired text
                        style: TextStyle(fontSize: 9), // Smaller font size
                      ),
                    ],
                  ),
                ] else ...[
                  const Text("Connected but no data received."),
                  ElevatedButton(
                    onPressed: () {
                      if (ModalRoute.of(context)?.settings.name != '/ble') {
                        Navigator.pushReplacementNamed(context, '/ble');
                      }
                    },
                    child: const Text("Go to BLE"),
                  ),
                ],
              ] else ...[
                GestureDetector(
                  onTap: () {
                    if (ModalRoute.of(context)?.settings.name != '/ble') {
                      Navigator.pushReplacementNamed(context, '/ble');
                    } // Navigate to BLE page
                  },
                  child: const Text(
                    "Not connected to any device. Tap here to connect.",
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}