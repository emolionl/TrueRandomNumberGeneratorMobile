import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:trng/helpers/database_helper.dart'; // Adjust the import based on your project structure
import 'package:cloud_firestore/cloud_firestore.dart';

class NetworkHelper {
  static Future<bool> hasInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<void> uploadSessionIfNeeded(BuildContext context, int sessionId) async {
    if (await hasInternetConnection()) {
      // Check if the session is already uploaded
      final sessionData = await DatabaseHelper.instance.getSessionData(sessionId);
      if (sessionData.isNotEmpty && !sessionData.first['session']['isUploaded']) {
        // Prepare data for upload
        Map<String, dynamic> firebaseData = {
          'sessionName': sessionData.first['session']['sessionName'],
          'totalTime': sessionData.first['session']['totalTime'].toString(),
          'createdAt': DateTime.fromMillisecondsSinceEpoch(sessionData.first['session']['createdAt']).toIso8601String(),
          'programs': {}
        };

        int programIndex = 0;
        sessionData.first['programs'].forEach((_, program) {
          List<Map<String, dynamic>> executions = List<Map<String, dynamic>>.from(program['executions']);
          firebaseData['programs'][programIndex.toString()] = {
            'name': program['name'],
            'duration': program['duration'].toString(),
            'executions': executions.map((execution) => {
              'value': execution['value'].toString(),
              'timestamp': DateTime.fromMillisecondsSinceEpoch(execution['timestamp']).toIso8601String(),
            }).toList(),
          };
          programIndex++;
        });

        // Upload to Firebase
        await FirebaseFirestore.instance.collection('sessions').add(firebaseData);
        // Mark session as uploaded in the local database
        await DatabaseHelper.instance.deleteSession(sessionId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session uploaded successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No session to upload or already uploaded')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection. Please try again later.')),
      );
    }
  }
}
