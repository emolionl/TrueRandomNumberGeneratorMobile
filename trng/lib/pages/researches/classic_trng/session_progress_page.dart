import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trng/helpers/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trng/models/program.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/ble_provider.dart';
import 'package:trng/helpers/network_helper.dart'; 
import 'package:logger/logger.dart';
import 'package:wakelock/wakelock.dart';


class SessionProgressPage extends StatefulWidget {
  final int sessionId;
  final List<Program> programs;
  const SessionProgressPage({super.key, required this.sessionId, required this.programs});
  @override
  SessionProgressPageState createState() => SessionProgressPageState();
}

class SessionProgressPageState extends State<SessionProgressPage> {
  int currentProgramIndex     = 0;
  int remainingTime           = 0;
  List<int> recentValues      = [];
  Timer? timer;
  BleProvider? bleProvider;
  List<int> valuesToInsertToDB = [];
  final logger                = Logger();
  
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    bleProvider = Provider.of<BleProvider>(context, listen: false);
    logger.i("widget.programs.isNotEmpty: $widget.programs.isNotEmpty");
    if (widget.programs.isNotEmpty) {
      startNextProgram();
    } else {
      finishSession();
    }
  }

  void startNextProgram() {
    logger.i("currentProgramIndex: $currentProgramIndex");
    logger.i(widget.programs.length);
    if (currentProgramIndex < widget.programs.length) {
      setState(() {
        remainingTime = widget.programs[currentProgramIndex].duration * 60;
      });
      bleProvider!.resetCounts(); // Added null check
      startTimer();
    } else {
      finishSession();
    }
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //logger.i("remainingTime: $remainingTime");
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
          if (bleProvider != null && (!bleProvider!.isConnected || bleProvider!.receivedData == null)) { // Check if not connected to TRNG
            recentValues.add(DateTime.now().millisecond % 2); // Simulating random 0/1
          }
        });
      } else {
        timer.cancel();
        currentProgramIndex++;
        startNextProgram();
      }
    });
  }

  Future<void> finishSession() async {
    logger.i("Starting finishSession()");
    currentProgramIndex++;
    if (await NetworkHelper.hasInternetConnection()){
      await NetworkHelper.uploadSessionIfNeeded(context, widget.sessionId);
      logger.i("Session uploaded and local data deleted");
      //Navigator.of(context).popUntil((route) => route.isFirst);
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content:  Text('There is no internet connection! it is not uploaded to server.')),
      );
      //Navigator.of(context).popUntil((route) => route.isFirst);
    }
    Wakelock.disable();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showWarningDialog,
      child: Scaffold(
        appBar: AppBar(title: Text(currentProgramIndex >= widget.programs.length ? 'Session Complete' : 'Session Progress'),),
        body: Center(
          child: Consumer<BleProvider>(
            builder: (context, bleProvider, child) {
              final receivedData = bleProvider.receivedData;

              if (currentProgramIndex >= widget.programs.length) {
                return Scaffold(
                  //appBar: AppBar(title: const Text('Session Complete')),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('All programs completed'),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/classic_trng_sessions');
                          },
                          child: const Text('View Sessions Details'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    receivedData != null ? "Receiving TRNG Numbers: $receivedData at ${DateTime.now().second.toString().padLeft(6, '0')}" : "No TRNG Numbers Received",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Time Remaining: ${remainingTime ~/ 60}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    children: [
                      Column(
                        children: [
                          Text(
                            bleProvider.receivedData != null
                                ? "Receiving TRNG Numbers: ${bleProvider.receivedData} at ${DateTime.now().second.toString().padLeft(6, '0')}"
                                : "No TRNG Numbers Received",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Current Program: ${widget.programs[currentProgramIndex].name}', // Added line for current program name
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Count of 1: ${bleProvider.count1}',
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Count of 0: ${bleProvider.count0}',
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Total: ${bleProvider.count0 + bleProvider.count1}',
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Percentage of Count 1: ${bleProvider.totalCount > 0 ? (bleProvider.count1 / bleProvider.totalCount * 100).toStringAsFixed(2) : 0}%',
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Percentage of Count 0: ${bleProvider.totalCount > 0 ? (bleProvider.count0 / bleProvider.totalCount * 100).toStringAsFixed(2) : 0}%',
                            style: const TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: Container(
          color: Colors.blue[100],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bleProvider != null && bleProvider?.isConnected == true ? "Connected to Bluetooth" : "Disconnected from Bluetooth",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                bleProvider?.receivedData != null ? "Receiving TRNG Numbers: ${bleProvider?.receivedData}" : "No TRNG Numbers Received",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showWarningDialog() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('Are you sure you want to go back? Your progress may be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return shouldPop ?? false; // Return false if dialog is dismissed
  }

  String getRemainingTimeFromTimer(Timer? timer) {
    if (timer == null) return '';
    // Replace with your actual logic to get the remaining time
    Duration totalDuration = const Duration(minutes: 30); // Example total duration
    Duration remaining = totalDuration - Duration(seconds: timer.tick); // Example logic
    return remaining.toString();
  }
}