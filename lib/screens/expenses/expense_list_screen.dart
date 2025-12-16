// lib/screens/expenses/expense_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/expense_model.dart';
import 'manage_expense_screen.dart';
import '../../widgets/expense_card.dart';
import 'package:intl/intl.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'date_newest_first';
  String _searchQuery = '';
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  List<Expense> _filterAndSearchExpenses(List<Expense> expenses) {
    return expenses.where((expense) {
      final matchesSearch = expense.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20, right: 20),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToAddExpense(context),
          backgroundColor: const Color(0xFF6366f1),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'ADD EXPENSE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpensesStream(
          category: _selectedCategory, 
          sortBy: _sortBy
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF6366f1),
              ),
            );
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: const Color(0xFFdc2626),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load expenses',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1f2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your connection',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFe0e7ff),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 48,
                        color: Color(0xFF4f46e5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No expenses yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1f2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start tracking your expenses\nby adding your first one',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFF6b7280),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final allExpenses = snapshot.data!;
          final filteredExpenses = _filterAndSearchExpenses(allExpenses);

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search expenses...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF9ca3af),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: const Color(0xFF6366f1),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: const Color(0xFF9ca3af),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFFe5e7eb),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFFe5e7eb),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: const Color(0xFF6366f1),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1f2937),
                  ),
                ),
              ),

              // Category Filter
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: Expense.categories.length + 1,
                  itemBuilder: (context, index) {
                    final category = index == 0 ? 'All' : Expense.categories[index - 1];
                    final isActive = category == _selectedCategory;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isActive ? Colors.white : const Color(0xFF4b5563),
                          ),
                        ),
                        selected: isActive,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : 'All';
                          });
                        },
                        backgroundColor: const Color(0xFFf3f4f6),
                        selectedColor: const Color(0xFF6366f1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Sort & Filter Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf3f4f6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort_rounded,
                            size: 16,
                            color: const Color(0xFF6366f1),
                          ),
                          const SizedBox(width: 6),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: const Color(0xFF6366f1),
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF4b5563),
                                fontWeight: FontWeight.w500,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'date_newest_first',
                                  child: Text('Newest First'),
                                ),
                                DropdownMenuItem(
                                  value: 'date_oldest_first',
                                  child: Text('Oldest First'),
                                ),
                                DropdownMenuItem(
                                  value: 'amount_high_to_low',
                                  child: Text('Amount High → Low'),
                                ),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _sortBy = newValue!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filteredExpenses.length} expenses',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 1,
                color: const Color(0xFFf3f4f6),
              ),

              // Expenses List
              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFf3f4f6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 32,
                                color: const Color(0xFF9ca3af),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1f2937),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF6b7280),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: _buildDismissibleExpenseCard(context, expense),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDismissibleExpenseCard(BuildContext context, Expense expense) {
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                  const SizedBox(width: 10),
                  const Text("Delete Expense"),
                ],
              ),
              content: Text("Are you sure you want to delete '${expense.name}'?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Delete"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _firestoreService.deleteExpense(expense.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${expense.name} deleted'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: ExpenseCard(
        expense: expense,
        onTap: () => _navigateToEditExpense(context, expense),
      ),
    );
  }

  void _navigateToAddExpense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ManageExpenseScreen(),
      ),
    );
  }

  void _navigateToEditExpense(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManageExpenseScreen(expenseToEdit: expense),
      ),
    );
  }
}