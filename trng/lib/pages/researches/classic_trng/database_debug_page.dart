import 'package:flutter/material.dart';
import 'package:trng/helpers/database_helper.dart';

class DatabaseDebugPage extends StatefulWidget {
  const DatabaseDebugPage({Key? key}) : super(key: key);
  @override
  _DatabaseDebugPageState createState() => _DatabaseDebugPageState();
}

class _DatabaseDebugPageState extends State<DatabaseDebugPage> {// Add const constructor
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Database Debug')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getAllData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var session = snapshot.data![index];
              return ExpansionTile(
                title: Text('Session: ${session['session']['sessionName']}'),
                children: [
                  Text('Total Time: ${session['session']['totalTime']}'),
                  ...(session['programs'] as List).map((program) {
                    return ExpansionTile(
                      title: Text('Program: ${program['name']}'),
                      children: [
                        Text('Duration: ${program['duration']}'),
                        Text('Executions: ${program['executions'].length}'),
                        if (program['executions'].isNotEmpty)
                          Text('First execution: ${program['executions'][0]}'),
                        if (program['executions'].length > 1)
                          Text('Last execution: ${program['executions'].last}'),
                        TextButton(
                          onPressed: () async {
                            int sessionId = session['session']['id']; // Adjust this based on your data structure
                            await DatabaseHelper.instance.deleteSession(sessionId);
                            setState(() {
                              snapshot.data!.removeAt(index); // Update the list
                            });
                          },
                          child: Text('Delete Session'),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.blue[100], // Change color as needed
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            ElevatedButton(
              onPressed: () async {
                // Call the reset database method here
                await DatabaseHelper.instance.resetDatabase(); // Ensure this method is defined in your state
              },
              child: const Text("Reset Database"),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getAllData() async {
    final db = await DatabaseHelper.instance.database;
    final sessions = await db.query('sessions');
    return Future.wait(sessions.map((session) async {
      final programs = await db.query('programs', where: 'sessionId = ?', whereArgs: [session['id']]);
      final programsWithExecutions = await Future.wait(programs.map((program) async {
        final executions = await db.query('program_executions', where: 'programId = ?', whereArgs: [program['id']]);
        return {...program, 'executions': executions};
      }));
      return {'session': session, 'programs': programsWithExecutions};
    }));
  }
}