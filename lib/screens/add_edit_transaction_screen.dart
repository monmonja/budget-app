import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../models/transaction.dart';
import '../services/data_service.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({super.key, this.transaction});

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _descriptionController.text = widget.transaction!.rawText;
      _amountController.text = widget.transaction!.amount?.toString() ?? '';
      _selectedDate = widget.transaction!.date ?? DateTime.now();
      _selectedCategory = widget.transaction!.inferredCategory;
      _selectedSubCategory = widget.transaction!.inferredSubCategory;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final newTransaction = Transaction(
        id: widget.transaction?.id ?? const Uuid().v4(),
        date: _selectedDate,
        amount: double.tryParse(_amountController.text),
        rawText: _descriptionController.text,
        inferredCategory: _selectedCategory,
        inferredSubCategory: _selectedSubCategory,
      );

      if (widget.transaction == null) {
        await DataService.addTransaction(newTransaction);
      } else {
        await DataService.updateTransaction(newTransaction);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  List<String> _getSubCategories() {
    if (_selectedCategory == null) return [];
    try {
      final category = initialCategories.firstWhere((c) => c.name == _selectedCategory);
      return category.subCategories;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final subCategories = _getSubCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Raw Text)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Category'),
                value: _selectedCategory,
                items: initialCategories.map((c) {
                  return DropdownMenuItem(
                    value: c.name,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedSubCategory = null;
                  });
                },
              ),
              if (subCategories.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Sub Category'),
                  value: _selectedSubCategory,
                  items: subCategories.map((sub) {
                    return DropdownMenuItem(
                      value: sub,
                      child: Text(sub),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubCategory = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text(isEditing ? 'Update Transaction' : 'Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
