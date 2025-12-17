// lib/screens/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart'; // Add this import
import '../../models/expense_model.dart'; // Add this import
import '../expenses/expense_list_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userEmail = '';
  double _monthlySpent = 0.0; // Initialize to 0.0
  String _currentTime = '';
  Timer? _timer;
  final FirestoreService _firestoreService = FirestoreService(); // Add Firestore service

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _updateTime();
    _loadMonthlySpent(); // Load monthly spent data
    
    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserEmail() async {
    final user = AuthService().getCurrentUser();
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? 'User';
      });
    }
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('hh:mm a').format(DateTime.now());
    });
  }

  Future<void> _loadMonthlySpent() async {
    try {
      // Get current month's start and end dates
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      // Get all expenses for the current user
      _firestoreService.getExpensesStream().listen((List<Expense> expenses) {
        // Filter expenses for current month
        final monthlyExpenses = expenses.where((expense) {
          return expense.date.isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
                 expense.date.isBefore(lastDayOfMonth.add(const Duration(days: 1)));
        }).toList();

        // Calculate total for current month
        double total = 0.0;
        for (var expense in monthlyExpenses) {
          total += expense.amount;
        }

        // Update UI
        if (mounted) {
          setState(() {
            _monthlySpent = total;
          });
        }
      });
    } catch (e) {
      print('Error loading monthly spent: $e');
      // Keep the default value (0.0)
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime currentDate = DateTime.now();
    
    return Scaffold(
      body: Column(
        children: [
          // Compact Gradient Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366f1),
                  const Color(0xFF8b5cf6),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // App Bar - No Back Arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // App Title - Centered
                    Expanded(
                      child: Text(
                        'Expense Tracker',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    
                    // Logout Icon
                    IconButton(
                      icon: Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _showLogoutDialog(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // User Info - Compact
                Row(
                  children: [
                    // User Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // User Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userEmail.isNotEmpty ? _userEmail.split('@')[0] : 'User',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM d, yyyy').format(currentDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Current Time
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentTime.isEmpty 
                            ? DateFormat('hh:mm a').format(DateTime.now())
                            : _currentTime,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Monthly Spending - Compact
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Spending',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        // Format the amount with 2 decimal places
                        NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(_monthlySpent),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'for ${DateFormat('MMMM yyyy').format(currentDate)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFf8fafc),
              child: const ExpenseListScreen(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: const Color(0xFFdc2626),
              size: 22,
            ),
            const SizedBox(width: 10),
            const Text(
              'Logout',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6b7280),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFdc2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}