import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trng/providers/database_provider.dart';
import 'package:trng/providers/auth_provider.dart';
import 'package:trng/widgets/custom_icon.dart';
import '../widgets/custom_drawer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseHelper>(context);
    final authProvider = Provider.of<AuthProvider>(context); // Add this line

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          CustomIcon(isLoggedIn: authProvider.user != null), // Pass the auth state
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut(context);
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await dbProvider.addUser(_nameController.text, _emailController.text);
                _nameController.clear();
                _emailController.clear();
              },
              child: const Text('Add User'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: dbProvider.usersStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final users = snapshot.data!;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          title: Text(user['name']),
                          subtitle: Text(user['email']),
                        );
                      },
                    );
                  } else {
                    return const Text('No users found.');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}