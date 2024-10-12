import 'package:flutter/material.dart';
import 'package:trng/helpers/database_helper.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SessionDetailPage extends StatelessWidget {
  final int sessionId;

  SessionDetailPage({required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Session Details')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getSessionPrograms(sessionId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final program = snapshot.data![index];
                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(program['name']),
                        subtitle: Text('Duration: ${program['duration']} minutes'),
                      ),
                      SizedBox(
                        height: 200,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: DatabaseHelper.instance.getProgramExecutions(program['id']),
                          builder: (context, executionSnapshot) {
                            if (executionSnapshot.hasData) {
                              final data = executionSnapshot.data!.asMap().entries.map((entry) {
                                return ExecutionData(entry.key, entry.value['value']);
                              }).toList();

                              return SfCartesianChart(
                                primaryXAxis: NumericAxis(),
                                series: <CartesianSeries<ExecutionData, int>>[
                                  LineSeries<ExecutionData, int>(
                                    dataSource: data,
                                    xValueMapper: (ExecutionData execution, _) => execution.index,
                                    yValueMapper: (ExecutionData execution, _) => execution.value,
                                  )
                                ],
                              );
                            } else if (executionSnapshot.hasError) {
                              return Text('Error: ${executionSnapshot.error}');
                            }
                            return CircularProgressIndicator();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class ExecutionData {
  final int index;
  final int value;

  ExecutionData(this.index, this.value);
}