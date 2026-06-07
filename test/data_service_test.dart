import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_app/models/category_rule.dart';
import 'package:budget_app/models/transaction.dart';
import 'package:budget_app/services/data_service.dart';

void main() {
  group('DataService', () {
    setUp(() {
      // Clear all SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('Category Rules', () {
      test('returns an empty list when no rules exist', () async {
        final rules = await DataService.getCategoryRules();
        expect(rules, isEmpty);
      });

      test('adds and retrieves a category rule', () async {
        final rule = CategoryRule(id: '1', keyword: 'coles', category: 'Grocery');
        await DataService.addCategoryRule(rule);

        final rules = await DataService.getCategoryRules();
        expect(rules.length, 1);
        expect(rules.first.keyword, 'coles');
      });

      test('deletes a category rule by id', () async {
        final rule1 = CategoryRule(id: '1', keyword: 'coles', category: 'Grocery');
        final rule2 = CategoryRule(id: '2', keyword: 'shell', category: 'Petrol');

        await DataService.addCategoryRule(rule1);
        await DataService.addCategoryRule(rule2);

        await DataService.deleteCategoryRule('1');

        final rules = await DataService.getCategoryRules();
        expect(rules.length, 1);
        expect(rules.first.id, '2');
      });
    });

    group('Transactions', () {
      test('returns an empty list when no transactions exist', () async {
        final transactions = await DataService.getTransactions();
        expect(transactions, isEmpty);
      });

      test('adds and retrieves a transaction', () async {
        final date = DateTime(2023, 1, 1);
        final transaction = Transaction(id: 't1', date: date, amount: 50.0, rawText: 'text');

        await DataService.addTransaction(transaction);

        final transactions = await DataService.getTransactions();
        expect(transactions.length, 1);
        expect(transactions.first.id, 't1');
        expect(transactions.first.amount, 50.0);
      });

      test('updates an existing transaction', () async {
        final date = DateTime(2023, 1, 1);
        final transaction = Transaction(id: 't1', date: date, amount: 50.0, rawText: 'text');
        await DataService.addTransaction(transaction);

        final updatedTransaction = Transaction(id: 't1', date: date, amount: 100.0, rawText: 'text updated', inferredCategory: 'Misc');
        await DataService.updateTransaction(updatedTransaction);

        final transactions = await DataService.getTransactions();
        expect(transactions.length, 1);
        expect(transactions.first.amount, 100.0);
        expect(transactions.first.rawText, 'text updated');
        expect(transactions.first.inferredCategory, 'Misc');
      });

      test('deletes a transaction by id', () async {
        final date = DateTime(2023, 1, 1);
        final t1 = Transaction(id: 't1', date: date, amount: 50.0, rawText: 'text 1');
        final t2 = Transaction(id: 't2', date: date, amount: 150.0, rawText: 'text 2');

        await DataService.addTransaction(t1);
        await DataService.addTransaction(t2);

        await DataService.deleteTransaction('t1');

        final transactions = await DataService.getTransactions();
        expect(transactions.length, 1);
        expect(transactions.first.id, 't2');
      });
    });

    group('Settings', () {
      test('returns default dashboard view when not set', () async {
        final view = await DataService.getDashboardView();
        expect(view, 'Weekly');
      });

      test('saves and retrieves dashboard view', () async {
        await DataService.saveDashboardView('Monthly');
        final view = await DataService.getDashboardView();
        expect(view, 'Monthly');
      });

      test('returns default start of week when not set', () async {
        final start = await DataService.getStartOfWeek();
        expect(start, 'Monday');
      });

      test('saves and retrieves start of week', () async {
        await DataService.saveStartOfWeek('Sunday');
        final start = await DataService.getStartOfWeek();
        expect(start, 'Sunday');
      });
    });
  });
}
