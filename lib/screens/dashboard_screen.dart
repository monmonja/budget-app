import 'package:flutter/material.dart';
import '../constants.dart';
import 'transaction_parse_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _budgetCycle = 'Weekly'; // Weekly or Fortnightly

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card),
            tooltip: 'Parse Transaction',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionParseScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Budget Cycle: ', style: TextStyle(fontSize: 18)),
                DropdownButton<String>(
                  value: _budgetCycle,
                  items: <String>['Weekly', 'Fortnightly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        _budgetCycle = newValue;
                        // In a real app we'd update all budget items
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: initialCategories.length,
              itemBuilder: (context, index) {
                final category = initialCategories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    title: Text(category.name),
                    subtitle: Text('Budget: \$${category.budgetAmount} ($_budgetCycle)'),
                    children: category.subCategories.isEmpty
                        ? [const Padding(padding: EdgeInsets.all(8.0), child: Text("No sub-categories"))]
                        : category.subCategories.map((sub) => ListTile(
                              title: Text(sub),
                              dense: true,
                            )).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
