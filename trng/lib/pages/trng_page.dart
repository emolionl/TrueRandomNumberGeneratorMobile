import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Add this import
import '../providers/serial_comm_provider.dart';
import '../widgets/custom_drawer.dart';

class TrngPage extends StatefulWidget {
  const TrngPage({super.key});

  @override
  _TrngPageState createState() => _TrngPageState();
}

class _TrngPageState extends State<TrngPage> {
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  late Stream<String> _broadcastStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final serialComm = Provider.of<SerialCommProvider>(context, listen: false);
      setState(() {
        _broadcastStream = serialComm.receivedData.asBroadcastStream();
      });
    });
  }

  @override
  void dispose() {
    _portController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRNG'),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _portController,
              decoration: const InputDecoration(labelText: 'Port Name'),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    await Provider.of<SerialCommProvider>(context, listen: false).connect(_portController.text);
                  },
                  child: const Text('Connect'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: Provider.of<SerialCommProvider>(context, listen: false).disconnect,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dataController,
              decoration: const InputDecoration(labelText: 'Data to Send'),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Provider.of<SerialCommProvider>(context, listen: false).sendData(_dataController.text);
                  },
                  child: const Text('Send Data'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<SerialCommProvider>(context, listen: false).sendData("restart\n"); // Send the "restart" command
                  },
                  child: const Text('Restart ESP32'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<void>(
                future: Future.delayed(Duration.zero), // Ensures the future completes immediately
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    return StreamBuilder<String>(
                      stream: _broadcastStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SingleChildScrollView(
                            child: Text('Received Data:\n${snapshot.data}'),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return const Text('No data received yet.');
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}