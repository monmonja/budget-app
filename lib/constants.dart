import 'package:budget_app/models/budget_category.dart';

final List<BudgetCategory> initialCategories = [
  BudgetCategory(name: 'Grocery'),
  BudgetCategory(name: 'Petrol'),
  BudgetCategory(name: 'Insurance'),
  BudgetCategory(name: 'House'),
  BudgetCategory(
    name: 'Utilities',
    subCategories: ['Electricity', 'Water', 'Internet', 'Mobile'],
  ),
  BudgetCategory(name: 'Phone'),
  BudgetCategory(name: 'Savings'),
  BudgetCategory(name: 'Misc'),
  BudgetCategory(name: 'Tithe'),
];
