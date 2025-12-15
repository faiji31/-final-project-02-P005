import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseCard({super.key, required this.expense, this.onTap});

  @override
  Widget build(BuildContext context) {
    IconData getCategoryIcon(String category) {
      switch (category) {
        case 'Food': return Icons.fastfood;
        case 'Transport': return Icons.directions_car;
        case 'Entertainment': return Icons.movie;
        case 'Shopping': return Icons.shopping_bag;
        case 'Bills': return Icons.receipt;
        case 'Other': return Icons.miscellaneous_services;
        default: return Icons.money;
      }
    }

    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            getCategoryIcon(expense.category),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          expense.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${expense.category} | ${DateFormat('MMM d, yyyy').format(expense.date)}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            if (expense.description != null && expense.description!.isNotEmpty)
              Text(
                expense.description!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormatter.format(expense.amount),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const Text(
              'Tap to edit',
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}