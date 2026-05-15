import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/entity_extraction_service.dart';
import '../models/transaction.dart';

class TransactionParseScreen extends StatefulWidget {
  const TransactionParseScreen({super.key});

  @override
  State<TransactionParseScreen> createState() => _TransactionParseScreenState();
}

class _TransactionParseScreenState extends State<TransactionParseScreen> {
  final TextEditingController _textController = TextEditingController();
  final EntityExtractionService _extractionService = EntityExtractionService();

  bool _isParsing = false;
  String _resultJson = '';

  @override
  void dispose() {
    _textController.dispose();
    _extractionService.dispose();
    super.dispose();
  }

  Future<void> _parseText() async {
    final text = _textController.text;
    if (text.isEmpty) return;

    setState(() {
      _isParsing = true;
      _resultJson = '';
    });

    try {
      Transaction transaction = await _extractionService.parseTransactionText(text);
      setState(() {
        _resultJson = const JsonEncoder.withIndent('  ').convert(transaction.toJson());
      });
    } catch (e) {
      setState(() {
        _resultJson = 'Error parsing: $e';
      });
    } finally {
      setState(() {
        _isParsing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parse Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Paste bank transaction text below:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g. 12/05/2023 Woolworths Grocery \$45.50',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isParsing ? null : _parseText,
              child: _isParsing
                  ? const CircularProgressIndicator()
                  : const Text('Parse Text'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Result JSON:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _resultJson,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
