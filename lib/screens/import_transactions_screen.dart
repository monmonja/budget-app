import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/data_service.dart';
import '../services/entity_extraction_service.dart';
import 'package:intl/intl.dart';

class ImportTransactionsScreen extends StatefulWidget {
  const ImportTransactionsScreen({super.key});

  @override
  State<ImportTransactionsScreen> createState() => _ImportTransactionsScreenState();
}

class _ImportTransactionsScreenState extends State<ImportTransactionsScreen> {
  final TextEditingController _textController = TextEditingController();
  final EntityExtractionService _extractionService = EntityExtractionService();

  bool _isParsing = false;
  bool _isSaving = false;
  List<Transaction> _parsedTransactions = [];

  @override
  void dispose() {
    _textController.dispose();
    _extractionService.dispose();
    super.dispose();
  }

  Future<void> _parseText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isParsing = true;
      _parsedTransactions = [];
    });

    final lines = text.split('\n');
    List<Transaction> results = [];

    try {
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        final t = await _extractionService.parseTransactionText(line.trim());
        results.add(t);
      }
      setState(() {
        _parsedTransactions = results;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing: $e')),
        );
      }
    } finally {
      setState(() {
        _isParsing = false;
      });
    }
  }

  Future<void> _saveAll() async {
    if (_parsedTransactions.isEmpty) return;

    setState(() {
      _isSaving = true;
    });

    try {
      for (final t in _parsedTransactions) {
        await DataService.addTransaction(t);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transactions saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Transactions'),
        actions: [
          if (_parsedTransactions.isNotEmpty)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveAll,
              tooltip: 'Save All',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste multi-line bank transaction text below:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g.\n12/05/2023 Woolworths Grocery \$45.50\nANZ INTERNET BANKING PAYMENT 455993 TO Barrabool Campus \$376.00',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isParsing ? null : _parseText,
              child: _isParsing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Parse Transactions'),
            ),
            const SizedBox(height: 16),
            if (_parsedTransactions.isNotEmpty) ...[
              const Text(
                'Preview Parsed Transactions:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _parsedTransactions.length,
                  itemBuilder: (context, index) {
                    final t = _parsedTransactions[index];
                    final dateStr = t.date != null
                        ? DateFormat('yyyy-MM-dd').format(t.date!)
                        : 'No Date';
                    final catStr = t.inferredCategory ?? "Uncategorized";
                    final amtStr = t.amount != null ? '\$${t.amount!.toStringAsFixed(2)}' : 'No Amount';

                    return Card(
                      child: ListTile(
                        title: Text(t.rawText, style: const TextStyle(fontSize: 14)),
                        subtitle: Text('$dateStr | $catStr | $amtStr'),
                      ),
                    );
                  },
                ),
              ),
            ] else if (_isParsing) ...[
               const Expanded(child: Center(child: Text('Parsing...')))
            ] else ...[
               const Expanded(child: Center(child: Text('No transactions parsed yet.')))
            ],
          ],
        ),
      ),
    );
  }
}
