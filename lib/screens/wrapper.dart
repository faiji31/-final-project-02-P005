// lib/screens/wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart'; // Create this screen next
import 'home/home_screen.dart'; // Create this screen next

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the auth state changes stream
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // 

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while checking the initial auth state
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          // User is not signed in, show the Login/Sign Up screen
          return const LoginScreen();
        } else {
          // User is signed in, show the Home screen
          return const HomeScreen();
        }
      },
    );
  }
}