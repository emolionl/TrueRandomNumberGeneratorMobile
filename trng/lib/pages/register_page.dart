import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart'; // Added this line
import 'package:provider/provider.dart';
import 'package:trng/providers/auth_provider.dart' as trng_auth;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  String? _errorMessage;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await firebase_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        Provider.of<trng_auth.AuthProvider>(context, listen: false).setUser(userCredential.user);

        // Navigate to the authenticated page
        Navigator.pushReplacementNamed(context, '/authenticated');
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _repeatPasswordController,
                decoration: InputDecoration(labelText: 'Repeat Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please repeat your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
              const SizedBox(height: 20),
              Text("Already have an account?"),
              TextButton(
              onPressed: () {
                if (ModalRoute.of(context)?.settings.name != '/login') {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: Text('Login'),
            ),
            ],
          ),
        ),
      ),
    );
  }
}