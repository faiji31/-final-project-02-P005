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
        userId: userId,
      );

      if (!isEditing) {
        await FirestoreService().addExpense(newExpense);
      } else {
        await FirestoreService().updateExpense(newExpense);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
        automaticallyImplyLeading: true, // This enables back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Expense Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Expense Name',
                  labelStyle: TextStyle(color: Colors.grey.shade700),
                  prefixIcon: Icon(Icons.label_outline, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(fontSize: 16),
                validator: (val) => val!.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.grey.shade700),
                  prefixIcon: Icon(Icons.attach_money, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                style: const TextStyle(fontSize: 16),
                validator: (val) {
                  if (val!.trim().isEmpty) return 'Enter an amount';
                  if (double.tryParse(val) == null || double.parse(val) <= 0) {
                    return 'Enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Picker
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                  title: Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.edit, color: Colors.grey),
                  onTap: _pickDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.grey.shade700),
                  prefixIcon: Icon(Icons.category_outlined, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: Expense.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) {
                      _selectedCategory = newValue;
                    }
                  });
                },
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(color: Colors.grey.shade700),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Save/Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveExpense,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(isEditing ? Icons.save : Icons.add),
                  label: Text(
                    _isLoading ? 'Saving...' : (isEditing ? 'Update Expense' : 'Add Expense'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
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