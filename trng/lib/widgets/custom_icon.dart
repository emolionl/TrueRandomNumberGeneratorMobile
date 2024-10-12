import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final bool isLoggedIn;

  const CustomIcon({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Container(); // Return an empty container if not logged in
    }

    return IconButton(
      icon: const Icon(Icons.person),
      onPressed: () {
        if (ModalRoute.of(context)?.settings.name != '/settings') {
          Navigator.pushReplacementNamed(context, '/settings');
        }
      },
    );
  }
}