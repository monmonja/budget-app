import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../constants.dart';
import '../models/category_rule.dart';
import '../services/data_service.dart';

class CategoryRulesScreen extends StatefulWidget {
  const CategoryRulesScreen({super.key});

  @override
  State<CategoryRulesScreen> createState() => _CategoryRulesScreenState();
}

class _CategoryRulesScreenState extends State<CategoryRulesScreen> {
  List<CategoryRule> _rules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    final rules = await DataService.getCategoryRules();
    setState(() {
      _rules = rules;
      _isLoading = false;
    });
  }

  Future<void> _deleteRule(String id) async {
    await DataService.deleteCategoryRule(id);
    _loadRules();
  }

  Future<void> _showAddRuleDialog() async {
    final keywordController = TextEditingController();
    String? selectedCategory;
    String? selectedSubCategory;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            List<String> subCategories = [];
            if (selectedCategory != null) {
              try {
                subCategories = initialCategories
                    .firstWhere((c) => c.name == selectedCategory)
                    .subCategories;
              } catch (e) {
                // ignore
              }
            }

            return AlertDialog(
              title: const Text('Add Category Rule'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: keywordController,
                      decoration: const InputDecoration(labelText: 'Keyword'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Category'),
                      value: selectedCategory,
                      items: initialCategories.map((c) {
                        return DropdownMenuItem(
                          value: c.name,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedCategory = value;
                          selectedSubCategory = null;
                        });
                      },
                    ),
                    if (subCategories.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Sub Category'),
                        value: selectedSubCategory,
                        items: subCategories.map((sub) {
                          return DropdownMenuItem(
                            value: sub,
                            child: Text(sub),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedSubCategory = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final keyword = keywordController.text.trim();
                    if (keyword.isNotEmpty && selectedCategory != null) {
                      final newRule = CategoryRule(
                        id: const Uuid().v4(),
                        keyword: keyword,
                        category: selectedCategory!,
                        subCategory: selectedSubCategory,
                      );
                      await DataService.addCategoryRule(newRule);
                      if (context.mounted) Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      _loadRules();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Rules'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _rules.isEmpty
              ? const Center(child: Text('No rules found. Add one!'))
              : ListView.builder(
                  itemCount: _rules.length,
                  itemBuilder: (context, index) {
                    final rule = _rules[index];
                    return ListTile(
                      title: Text(rule.keyword),
                      subtitle: Text('${rule.category}${rule.subCategory != null ? ' - ${rule.subCategory}' : ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRule(rule.id),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRuleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
