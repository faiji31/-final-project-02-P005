// lib/screens/expenses/expense_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/expense_model.dart';
import 'manage_expense_screen.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/total_summary_card.dart';
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

  Map<String, double> _calculateTotals(List<Expense> expenses) {
    double grandTotal = 0.0;
    final Map<String, double> categoryTotals = {};

    for (var category in Expense.categories) {
      categoryTotals[category] = 0.0;
    }

    for (var expense in expenses) {
      grandTotal += expense.amount;
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }

    categoryTotals['All'] = grandTotal;
    return categoryTotals;
  }

  List<Expense> _filterAndSearchExpenses(List<Expense> expenses) {
    return expenses.where((expense) {
      // Search is done client-side after the stream fetches data
      final matchesSearch = expense.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddExpense(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpensesStream(
          category: _selectedCategory, 
          sortBy: _sortBy
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // FIX: This will show the INDEX ERROR URL if it occurs
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Database Error: ${snapshot.error}. If this mentions INDEXING, click the link provided in the console!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                  ),
                ));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No expenses found. Start adding some!', style: TextStyle(fontSize: 16)),
            );
          }

          final allExpenses = snapshot.data!;
          final totals = _calculateTotals(allExpenses);
          final filteredExpenses = _filterAndSearchExpenses(allExpenses);

          return Column(
            children: [
              TotalSummaryCard(
                grandTotal: totals['All'] ?? 0.0,
                categoryTotals: totals,
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search Expenses by Name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

              _buildCategoryFilterBar(totals),
              _buildSortDropdown(),

              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(child: Text('No expenses matching "$_searchQuery" in $_selectedCategory'))
                    : ListView.builder(
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          return _buildDismissibleExpenseCard(context, expense);
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
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Delete"),
              content: Text("Are you sure you want to delete '${expense.name}'?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _firestoreService.deleteExpense(expense.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${expense.name} deleted')),
        );
      },
      child: ExpenseCard(
        expense: expense,
        onTap: () => _navigateToEditExpense(context, expense),
      ),
    );
  }

  Widget _buildCategoryFilterBar(Map<String, double> totals) {
    final allCategories = ['All', ...Expense.categories];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isActive = category == _selectedCategory;
          final total = totals[category] ?? 0.0;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ActionChip(
              label: Text(
                '$category (${NumberFormat.currency(symbol: '\$').format(total)})',
                style: TextStyle(
                  color: isActive ? Colors.white : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: isActive ? Theme.of(context).primaryColor : Colors.grey[200],
              onPressed: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: isActive ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.sort, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'date_newest_first', child: Text('Date (Newest First)')),
                  DropdownMenuItem(value: 'date_oldest_first', child: Text('Date (Oldest First)')),
                  DropdownMenuItem(value: 'amount_high_to_low', child: Text('Amount (High to Low)')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _sortBy = newValue!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddExpense(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ManageExpenseScreen()),
    );
  }

  void _navigateToEditExpense(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ManageExpenseScreen(expenseToEdit: expense)),
    );
  }
}