import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/auth_provider.dart';
import 'package:trng/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final authProvider = context.read<AuthProvider>();
                final email = _emailController.text;
                final password = _passwordController.text;

                String? errorMessage = await authProvider.signInWithEmailAndPassword(email, password);
                if (errorMessage != null) {
                  setState(() {
                    _errorText = errorMessage;
                  });
                } else {
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                }
              },
              child: Text('Login'),
            ),
            if (_errorText != null)
              Text(
                _errorText!,
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            Text("Don't have an account?"),
            TextButton(
              onPressed: () {
                if (ModalRoute.of(context)?.settings.name != '/register') {
                  Navigator.pushReplacementNamed(context, '/register');
                }
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}