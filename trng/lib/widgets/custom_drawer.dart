import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 56,
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
            child: const Center(
              child: Text(
                'menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (authProvider.user != null) ...[
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Dashboard'),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/dashboard') {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                }
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.casino), // Icon representing randomness
              title: const Text('Classic TRNG'),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('New Session'),
                  onTap: () {
                    if (ModalRoute.of(context)?.settings.name != '/classic_trng') {
                      Navigator.pushReplacementNamed(context, '/classic_trng');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('Results'),
                  onTap: () {
                    if (ModalRoute.of(context)?.settings.name != '/classic_trng_sessions') {
                      Navigator.pushReplacementNamed(context, '/classic_trng_sessions');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Database Debug'),
                  onTap: () {
                    if (ModalRoute.of(context)?.settings.name != '/database_debug') {
                      Navigator.pushReplacementNamed(context, '/database_debug');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            ListTile(
              leading: const Icon(Icons.bluetooth),
              title: const Text('Bluetooth'),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/ble') {
                  Navigator.pushReplacementNamed(context, '/ble');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/settings') {
                  Navigator.pushReplacementNamed(context, '/settings');
                }
              },
            ),

            ListTile(
              leading: Icon(Icons.app_registration),
              title: Text('Test device connection'),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/connection_device-test') {
                  Navigator.pushReplacementNamed(context, '/connection_device-test');
                }
              },
            ),
            const SizedBox(height: 40),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await authProvider.signOut(context);
                if (ModalRoute.of(context)?.settings.name != '/') {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Welcome'),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/') {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Login'),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/login') {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.app_registration),
              title: Text('Register'),
              onTap: () {
                if (ModalRoute.of(context)?.settings.name != '/register') {
                  Navigator.pushReplacementNamed(context, '/register');
                }
              },
            ),
            
          ],
        ],
      ),
    );
  }
}