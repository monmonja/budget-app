import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../services/data_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _dashboardView = 'Weekly';
  String _startOfWeek = 'Monday';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final view = await DataService.getDashboardView();
    final start = await DataService.getStartOfWeek();
    setState(() {
      _dashboardView = view;
      _startOfWeek = start;
    });
  }

  String _getCycleDates() {
    final now = DateTime.now();

    // Determine the target weekday (1 = Monday, 7 = Sunday)
    int targetWeekday = 1;
    switch (_startOfWeek) {
      case 'Monday': targetWeekday = 1; break;
      case 'Tuesday': targetWeekday = 2; break;
      case 'Wednesday': targetWeekday = 3; break;
      case 'Thursday': targetWeekday = 4; break;
      case 'Friday': targetWeekday = 5; break;
      case 'Saturday': targetWeekday = 6; break;
      case 'Sunday': targetWeekday = 7; break;
    }

    // Find the start date based on the target weekday
    // We go backwards until we hit the target weekday.
    int daysToSubtract = now.weekday - targetWeekday;
    if (daysToSubtract < 0) {
      daysToSubtract += 7;
    }

    DateTime cycleStart = now.subtract(Duration(days: daysToSubtract));
    DateTime cycleEnd;

    if (_dashboardView == 'Weekly') {
      cycleEnd = cycleStart.add(const Duration(days: 6));
    } else if (_dashboardView == 'Fortnightly') {
      cycleEnd = cycleStart.add(const Duration(days: 13));
    } else if (_dashboardView == 'Monthly') {
      // Monthly view usually aligns with the start of the month,
      // but if we are following 'startOfWeek', it can be tricky.
      // Let's just do a 4-week cycle or start of the month for simplicity.
      // Assuming a 4-week (28 days) cycle for 'Monthly' starting on the start of the week.
      cycleEnd = cycleStart.add(const Duration(days: 27));
    } else {
      cycleEnd = cycleStart.add(const Duration(days: 6));
    }

    final format = DateFormat('MMM d');
    return '${format.format(cycleStart)} - ${format.format(cycleEnd)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Dashboard'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('View: $_dashboardView', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_getCycleDates(), style: const TextStyle(fontSize: 16, color: Colors.grey)),
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
                    subtitle: Text('Budget: \$${category.budgetAmount} ($_dashboardView)'),
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
