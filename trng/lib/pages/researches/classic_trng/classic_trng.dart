import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/models/program.dart';
import 'package:trng/pages/researches/classic_trng/session_progress_page.dart';
import 'package:trng/providers/auth_provider.dart';
import 'package:trng/helpers/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:trng/pages/researches/classic_trng/session_list_page.dart';
import 'package:trng/providers/ble_provider.dart'; // Import BleProvider
import 'dart:math';
import 'package:logger/logger.dart';
import 'package:flutter/gestures.dart';

class ClassicTrng extends StatefulWidget {
  const ClassicTrng({super.key});

  @override
  _ClassicTrngState createState() => _ClassicTrngState();
}

class _ClassicTrngState extends State<ClassicTrng> {
  List<Program> programs      = [];
  String sessionName          = "";
  int? sessionId;
  List<Timer> dataCollectionTimers = [];
  bool isBleConnected         = false; // Track BLE connection status
  int trngValue               = -1; // Initialize TRNG value
  String statusMessage        = ''; // Status message for Bluetooth connection
  Random random               = Random();
  final logger                = Logger();

  int get totalSessionTime => programs.fold(0, (sum, program) => sum + program.duration);

  @override
  void dispose() {
    // Cancel all timers when the widget is disposed
    for (var timer in dataCollectionTimers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bleProvider = Provider.of<BleProvider>(context);
    isBleConnected = bleProvider.isConnected;
    // Update status message based on connection and TRNG value
    // if (bleProvider.receivedData != null) {
    //   statusMessage = 'Connected and receiving data: ${bleProvider.receivedData ?? ''}'; // Use string interpolation
    // } else {
    //   statusMessage = 'Not connected and not receiving daata, go to bluetooth page to connect';
    // }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create New Session", style: Theme.of(context).textTheme.titleLarge),
            Text("The session encompasses everything, while the program is just one component of the session, with at least one program required, though there can be many more.", style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Session Name'),
              onChanged: (value) {
                setState(() {
                  sessionName = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Text('Total Session Time: $totalSessionTime minutes',style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  programs.add(Program(name: '', duration: 0));
                });
              },
              child: const Text('Add new program'),
            ),
            const SizedBox(height: 20),
            ...programs.asMap().entries.map((entry) {
              int idx = entry.key;
              Program program = entry.value;
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: 100, // Set your desired width
                          height: 50, // Set your desired height
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Program Name'),
                            onChanged: (value) {
                              setState(() {
                                programs[idx].name = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: program.duration.toDouble(),
                                min: 0,
                                max: 120, // Maximum 2 hours per program
                                divisions: 120,
                                label: '${program.duration} minutes',
                                onChanged: (double value) {
                                  setState(() {
                                    programs[idx].duration = value.round();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 1),
                            SizedBox(
                              width: 30,
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Min'),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(text: program.duration.toString()),
                                onChanged: (value) {
                                  setState(() {
                                    programs[idx].duration = int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            programs.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _startSession(context, bleProvider);
              },
              child: const Text('Start Session'),
            ),
            const SizedBox(height: 20),
            // Status indicator for Bluetooth connection and TRNG value
           RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: isBleConnected && bleProvider.receivedData != null
                        ? 'Connected and receiving data: ${bleProvider.receivedData ?? ''}'
                        : 'Not connected and not receiving data, ',
                    style: TextStyle(
                      fontSize: 16,
                      color: isBleConnected && bleProvider.receivedData != null
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  if (!isBleConnected || bleProvider.receivedData == null) // Show link only if not connected or not receiving data
                    TextSpan(
                      text: 'go to bluetooth page to connect',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue, // Link color
                        decoration: TextDecoration.underline, // Underline for link
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () { 
                        Navigator.pushReplacementNamed(context, '/ble');// Navigate to Bluetooth page
                      },
                    ),
                ],
              ),
            ),
            
            // Text(
            //   statusMessage,
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: isBleConnected ? Colors.green : Colors.red,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _startSession(BuildContext context, BleProvider bleProvider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to start a session')),
      );
      return;
    }

    if (programs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one program to the session')),
      );
      return;
    }

    for (int idx = 0; idx < programs.length; idx++) { // Define idx in a loop
      if (programs[idx].duration < 1) { // Check if duration is less than 1
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Choose at least one minute at program'),
          ),
        );
        return;
      }
    }

    if (isBleConnected) {
      // Check for data from ESP32
      trngValue = await bleProvider.getTrngData(); // Use BleProvider to get TRNG data
      if (trngValue < 0) { // Check if the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to receive TRNG data from device')),
        );
        return;
      }
      setState(() {
        statusMessage = 'Connected: TRNG Value: $trngValue'; // Update status message with received TRNG value
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No BLE connection established'),
          action: SnackBarAction(
            label: 'Go to BLE',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/ble');
            },
          ),
        ),
      );
      return;
    }

    try {
      // Insert session into SQLite
      sessionId = await DatabaseHelper.instance.insertSession({
        'sessionName': sessionName,
        'totalTime': totalSessionTime,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Insert programs into SQLite and start data collection for each
      for (var program in programs) {
        final programId = await DatabaseHelper.instance.insertProgram({
          'sessionId': sessionId,
          'name': program.name,
          'duration': program.duration,
        });
        _collectData(programId, program.duration);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session started successfully')),
      );

      if (sessionId != null) {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SessionProgressPage(
            sessionId: sessionId!,
            programs: programs,
          ),
        ));
      }

    } catch (e) {
      print('Error starting session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start session: ${e.toString()}')),
      );
    }
  }

  void _collectData(int programId, int durationMinutes) {
    int elapsedSeconds = 0;
    Timer timer = Timer.periodic(Duration(milliseconds: 250), (timer) {
      if (elapsedSeconds >= durationMinutes * 60) {
        timer.cancel();
        return;
      }

      // Use the TRNG value instead of random value
      int valueToInsert = trngValue == 0 || trngValue == 1 ? trngValue : random.nextInt(2); // Fallback to random if TRNG fails
      DatabaseHelper.instance.insertProgramExecution({
        'programId': programId,
        'value': valueToInsert,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }).then((id) => logger.i('Inserted execution for program $programId: value=$valueToInsert'));

      elapsedSeconds += 1;
    });

    dataCollectionTimers.add(timer);
  }

  void _endSession() async {
    if (sessionId == null) return;

    // Cancel all data collection timers
    for (var timer in dataCollectionTimers) {
      timer.cancel();
    }
    dataCollectionTimers.clear();

    try {
      // Retrieve all session data from SQLite
      final sessionData = await DatabaseHelper.instance.getSessionData(sessionId!);

      // Upload to Firebase
      await FirebaseFirestore.instance.collection('sessions').add(sessionData.first);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session uploaded to Firebase successfully')),
      );

      // Navigate to SessionListPage after ending the session
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SessionListPage()),
      );
    } catch (e) {
      print('Error uploading session to Firebase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload session to Firebase: ${e.toString()}')),
      );
    }
  }
}
