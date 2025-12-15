// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLogin = true;
  bool _isLoading = false;

  // Use a global key for the form to handle validation
  final _formKey = GlobalKey<FormState>();

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is not valid
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    String? error;

    if (_isLogin) {
      error = await _authService.signIn(email: email, password: password);
    } else {
      error = await _authService.signUp(email: email, password: password);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define an accent color for the cool design
    const Color accentColor = Color(0xFF4C7FFF); // A nice blue
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      // 1. Use a gradient background for a modern look
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 2. App Logo/Title with a modern icon
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: accentColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Expense Tracker',
                    style: textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 3. Elevated Card for the form for visual grouping
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Form Title
                          Text(
                            _isLogin ? 'Welcome Back' : 'Create Account',
                            style: textTheme.headlineSmall!.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email Input Field
                          TextFormField(
                            controller: _emailController,
                            decoration: _inputDecoration(
                              'Email Address',
                              Icons.email_outlined,
                              accentColor,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) =>
                                val!.isEmpty ? 'Enter an email' : null,
                          ),
                          const SizedBox(height: 16),

                          // Password Input Field
                          TextFormField(
                            controller: _passwordController,
                            decoration: _inputDecoration(
                              'Password',
                              Icons.lock_outline,
                              accentColor,
                            ),
                            obscureText: true,
                            validator: (val) => val!.length < 6
                                ? 'Password must be 6+ chars long'
                                : null,
                          ),
                          const SizedBox(height: 32),

                          // 4. Custom shaped and colored button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _authenticate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      _isLogin ? 'Sign In' : 'Register',
                                      style: textTheme.titleMedium!.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Toggle Button
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                                // Clear fields when switching
                                _emailController.clear();
                                _passwordController.clear();
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Need an account? Sign Up'
                                  : 'Already have an account? Sign In',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function for a consistent, cool input field decoration
  InputDecoration _inputDecoration(
      String label, IconData icon, Color accentColor) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accentColor.withOpacity(0.8)),
      prefixIcon: Icon(icon, color: accentColor),
      filled: true,
      fillColor: accentColor.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none, // Hide default border
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accentColor.withOpacity(0.5), width: 1),
      ),
    );
  }
}