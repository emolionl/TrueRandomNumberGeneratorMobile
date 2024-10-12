import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/auth_provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user != null) {
      return child;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to access this page.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Container(); // Return an empty container while redirecting
    }
  }
}