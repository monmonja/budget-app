import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../services/data_service.dart';
import 'add_edit_transaction_screen.dart';
import 'import_transactions_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await DataService.getTransactions();
    // Sort transactions by date descending
    transactions.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  Future<void> _deleteTransaction(String id) async {
    await DataService.deleteTransaction(id);
    _loadTransactions();
  }

  Future<void> _navigateToAddEditScreen([Transaction? transaction]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(transaction: transaction),
      ),
    );

    // If true is returned, the transaction was saved, so reload the list
    if (result == true) {
      _loadTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Import Transactions',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ImportTransactionsScreen()),
              );
              if (result == true) {
                _loadTransactions();
              }
            },
          )
        ],
      ),
      body: _transactions.isEmpty
          ? const Center(child: Text('No transactions found.'))
          : ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                final dateStr = transaction.date != null
                    ? DateFormat('yyyy-MM-dd').format(transaction.date!)
                    : 'No Date';

                return Dismissible(
                  key: Key(transaction.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteTransaction(transaction.id);
                  },
                  child: ListTile(
                    title: Text(transaction.rawText),
                    subtitle: Text('$dateStr | ${transaction.inferredCategory ?? "Uncategorized"}'),
                    trailing: Text(
                      transaction.amount != null ? '\$${transaction.amount!.toStringAsFixed(2)}' : '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    onTap: () => _navigateToAddEditScreen(transaction),
                  ),
                );
              },
            ),
    );
  }
}
