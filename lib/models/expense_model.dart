// lib/models/expense_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String category;
  final String? description;
  final DateTime createdAt;
  final String userId; // CRITICAL: This must be present and correctly named 'userId'

  static const List<String> categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Bills',
    'Other',
  ];

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    this.description,
    required this.createdAt,
    required this.userId,
  });

  // Convert Firestore Document to Expense object
  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      name: data['name'] as String,
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'] as String,
      description: data['description'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] as String,
    );
  }

  // Convert Expense object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'date': date,
      'category': category,
      'description': description,
      'createdAt': createdAt,
      'userId': userId, // CRITICAL: This 'userId' field powers the security rules
    };
  }
}