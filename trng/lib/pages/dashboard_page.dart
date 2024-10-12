import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/auth_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Welcome, ${authProvider.user?.email ?? 'User'}!'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to other pages or perform actions
            },
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }
}