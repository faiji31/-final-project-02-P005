// lib/widgets/total_summary_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalSummaryCard extends StatelessWidget {
  final double grandTotal;
  final Map<String, double> categoryTotals;

  const TotalSummaryCard({
    super.key,
    required this.grandTotal,
    required this.categoryTotals,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$');

    
    // Sort categories by amount descending for the list //sortin
    final sortedCategories = categoryTotals.entries
        .where((e) => e.key != 'All')
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grand Total Display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Expenses:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black87),
                ),
                Text(
                  currencyFormatter.format(grandTotal),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            // Category Breakdown Title
            const Text(
              'Category Breakdown:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
            const SizedBox(height: 8),

            // Category 
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120), // Limit height for cleaner UI
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Use ScrollController on parent if needed
                itemCount: sortedCategories.length,
                itemBuilder: (context, index) {
                  final entry = sortedCategories[index];
                  if (entry.value == 0) return const SizedBox.shrink(); // Hide zero entries

                  final percentage = grandTotal > 0 ? (entry.value / grandTotal) : 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          '${currencyFormatter.format(entry.value)} (${(percentage * 100).toStringAsFixed(1)}%)',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}