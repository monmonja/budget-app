import 'package:flutter_test/flutter_test.dart';
import 'package:budget_app/models/budget_category.dart';
import 'package:budget_app/models/transaction.dart';

void main() {
  group('Data Models Test', () {
    test('BudgetCategory should initialize correctly and serialize to JSON', () {
      final category = BudgetCategory(
        name: 'Utilities',
        subCategories: ['Electricity', 'Water'],
        budgetAmount: 100.0,
        budgetType: 'Fortnightly',
      );

      expect(category.name, 'Utilities');
      expect(category.subCategories, ['Electricity', 'Water']);
      expect(category.budgetAmount, 100.0);
      expect(category.budgetType, 'Fortnightly');

      final json = category.toJson();
      expect(json['name'], 'Utilities');
      expect(json['subCategories'], ['Electricity', 'Water']);
      expect(json['budgetAmount'], 100.0);
      expect(json['budgetType'], 'Fortnightly');
    });

    test('Transaction should initialize correctly and serialize to JSON', () {
      final now = DateTime.now();
      final transaction = Transaction(
        date: now,
        amount: 50.0,
        rawText: 'Woolworths 50.0',
        inferredCategory: 'Grocery',
      );

      expect(transaction.date, now);
      expect(transaction.amount, 50.0);
      expect(transaction.rawText, 'Woolworths 50.0');
      expect(transaction.inferredCategory, 'Grocery');

      final json = transaction.toJson();
      expect(json['date'], now.toIso8601String());
      expect(json['amount'], 50.0);
      expect(json['rawText'], 'Woolworths 50.0');
      expect(json['inferredCategory'], 'Grocery');
      expect(json['inferredSubCategory'], null);
    });
  });
}
