import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/auth_provider.dart';
import 'package:trng/widgets/custom_drawer.dart';
import 'package:trng/widgets/custom_icon.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;

  const ResponsiveScaffold({required this.body, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);


    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 600) {
          // Larger screen, show side menu
          return Scaffold(
            appBar: AppBar(
              title: Text("TRNG - " + title),
              actions: [
                if (authProvider.user != null) ...[
                  CustomIcon(isLoggedIn: authProvider.user != null),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: () {
                      if (ModalRoute.of(context)?.settings.name != '/login') {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.app_registration),
                    onPressed: () {
                      if (ModalRoute.of(context)?.settings.name != '/register') {
                        Navigator.pushReplacementNamed(context, '/register');
                      }
                    },
                  ),
                ],
              ],
            ),
            body: Row(
              children: [
                const SizedBox(
                  width: 170, // Adjust this value to set the desired width
                  child: CustomDrawer(), // Side menu
                ),
                Expanded(child: body),
              ],
            ),
          );
        } else {
          // Smaller screen, show hamburger menu
          return Scaffold(
            appBar: AppBar(
              title: Text("TRNG - " + title),
              actions: [
                if (authProvider.user != null) ...[
                  CustomIcon(isLoggedIn: authProvider.user != null),
                ] else ...[
                  IconButton(
                    icon: const Icon(Icons.login),
                    onPressed: () {
                      if (ModalRoute.of(context)?.settings.name != '/login') {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.app_registration),
                    onPressed: () {
                      if (ModalRoute.of(context)?.settings.name != '/register') {
                        Navigator.pushReplacementNamed(context, '/register');
                      }  
                    },
                  ),
                ],
              ],
            ),
            drawer: const CustomDrawer(), // Hamburger menu
            body: body,
          );
        }
      },
    );
  }
}