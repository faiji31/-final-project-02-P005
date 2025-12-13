// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService().getCurrentUser()?.email ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home - Expense Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, $userEmail!'),
            const SizedBox(height: 10),
            const Text('You are now logged in. Start managing expenses!'),
          ],
        ),
      ),
    );
  }
}