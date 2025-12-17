// lib/widgets/expense_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key, 
    required this.expense, 
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Helper to get a category-specific icon
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

    // Helper to format currency
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Category Icon
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  getCategoryIcon(expense.category),
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              
              // Expense Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
              ),
              
              // Amount and Delete Icon
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Amount
                  Column(
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
                  
                  // Delete Icon
                  if (onDelete != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        onPressed: onDelete,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        tooltip: 'Delete expense',
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}