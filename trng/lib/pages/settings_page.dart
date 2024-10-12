import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: Text('Welcome ${authProvider.user?.email} to the Settings Page'),
      ),
    );
  }
}