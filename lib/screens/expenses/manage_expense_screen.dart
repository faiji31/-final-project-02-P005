// lib/screens/expenses/manage_expense_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class ManageExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;

  const ManageExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<ManageExpenseScreen> createState() => _ManageExpenseScreenState();
}

class _ManageExpenseScreenState extends State<ManageExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = Expense.categories.first;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final expense = widget.expenseToEdit!;
      _nameController.text = expense.name;
      _amountController.text = expense.amount.toStringAsFixed(2);
      _descriptionController.text = expense.description ?? '';
      _selectedCategory = expense.category;
      _selectedDate = expense.date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = AuthService().getCurrentUser()!.uid;
      final isEditing = widget.expenseToEdit != null;

      final newExpense = Expense(
        id: isEditing ? widget.expenseToEdit!.id : '',
        name: _nameController.text.trim(),
        amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
        date: _selectedDate,
        category: _selectedCategory,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        createdAt: isEditing ? widget.expenseToEdit!.createdAt : DateTime.now(),
        userId: userId, // CRITICAL: Ensure userId is set here
      );

      if (!isEditing) {
        await FirestoreService().addExpense(newExpense);
      } else {
        await FirestoreService().updateExpense(newExpense);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save expense: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expenseToEdit != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add New Expense'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Expense Name',
                  prefixIcon: Icon(Icons.label_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val!.trim().isEmpty) return 'Enter an amount';
                  if (double.tryParse(val) == null || double.parse(val) <= 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.edit),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items:
                    Expense.categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveExpense,
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(isEditing ? 'Update Expense' : 'Add Expense'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
