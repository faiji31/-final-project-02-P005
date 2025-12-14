import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  CollectionReference<Map<String, dynamic>> _getExpensesCollection() {
    return _db.collection('expenses');
  }

  // C - Create Expense
  Future<void> addExpense(Expense expense) async {
    try {
      await _getExpensesCollection().add(expense.toMap());
    } catch (e) {
      print('Failed to add expense: $e');
      // Re-throwing allows the calling UI layer to handle the error (e.g., show a toast).
      rethrow;
    }
  }

  // R - Read Expenses (Stream for Real-time Sync)
  Stream<List<Expense>> getExpensesStream({String? category, String? sortBy}) {
    final userId = _authService.getCurrentUser()?.uid;

    // CRITICAL: Prevent query if user is null (avoids Permission Denied error)
    if (userId == null) {
      return const Stream.empty();
    }

    // Start with the base query filtered by the logged-in user ID
    Query query = _getExpensesCollection().where('userId', isEqualTo: userId);

    // 1. Category Filter
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    // 2. Sort Logic
    String primaryOrderByField = 'date';
    bool primaryDescending = true;
    String? secondaryOrderByField;
    bool secondaryDescending = true;

    if (sortBy == 'amount_high_to_low') {
      primaryOrderByField = 'amount';
    } else if (sortBy == 'date_oldest_first') {
      primaryDescending = false;
    }

    // Add a secondary sort field to ensure deterministic order,
    // especially when the primary sort field might have duplicate values (like amount).
    // The 'date' or a 'createdAt' field is a good choice for a secondary sort.
    if (primaryOrderByField != 'date') {
      // If sorting by amount, use 'date' as a tie-breaker.
      // NOTE: This requires a composite index that includes userId, category (if filtered), amount, and date.
      secondaryOrderByField = 'date';
      secondaryDescending = true; // Use newest date as a tie-breaker (common sense)
    }


    // Apply the primary sort field
    query = query.orderBy(primaryOrderByField, descending: primaryDescending);

    // Apply the secondary sort field (if necessary)
    if (secondaryOrderByField != null) {
      query = query.orderBy(secondaryOrderByField, descending: secondaryDescending);
    }


    // Final query execution
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    });
  }

  // U - Update Expense
  Future<void> updateExpense(Expense expense) async {
    // Ensure the expense has an ID before trying to update
    if (expense.id == null) {
      throw Exception('Cannot update expense: ID is null.');
    }
    try {
      await _getExpensesCollection().doc(expense.id).update(expense.toMap());
    } catch (e) {
      print('Failed to update expense: $e');
      rethrow;
    }
  }

  // D - Delete Expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _getExpensesCollection().doc(expenseId).delete();
    } catch (e) {
      print('Failed to delete expense: $e');
      rethrow;
    }
  }
}