import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/test_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to the magic'),
      ),
      //drawer: const CustomDrawer(),
      body: const Center(
        child: Text("home page"),
      ),
    );
  }
}