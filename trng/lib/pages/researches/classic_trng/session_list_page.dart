import 'package:flutter/material.dart';
import 'package:trng/helpers/database_helper.dart';
import 'package:trng/pages/researches/classic_trng/session_detail_page.dart';

class SessionListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Sessions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/classic_trng'); // Navigate to the same route
        },
        
        child: Icon(Icons.add), // Icon for the FAB
        tooltip: 'New Session', // Tooltip for accessibility
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getSessions(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final session = snapshot.data![index];
                return ListTile(
                  title: Text(session['sessionName']),
                  subtitle: Text('Total Time: ${session['totalTime']} minutes'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionDetailPage(sessionId: session['id']),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
