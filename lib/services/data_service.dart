import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/transaction.dart';

class DataService {
  static const String _keyDashboardView = 'dashboard_view';
  static const String _keyStartOfWeek = 'start_of_week';
  static const String _keyTransactions = 'transactions_history';

  // Transactions
  static Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_keyTransactions);
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Transaction.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error decoding transactions: $e');
      return [];
    }
  }

  static Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTransactions, jsonString);
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  static Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    await saveTransactions(transactions);
  }

  // Settings
  static Future<String> getDashboardView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDashboardView) ?? 'Weekly';
  }

  static Future<void> saveDashboardView(String view) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDashboardView, view);
  }

  static Future<String> getStartOfWeek() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStartOfWeek) ?? 'Monday';
  }

  static Future<void> saveStartOfWeek(String start) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStartOfWeek, start);
  }

  // Backup & Restore
  static Future<void> exportToZip() async {
    final prefs = await SharedPreferences.getInstance();

    final transactions = await getTransactions();

    final Map<String, dynamic> exportData = {
      'settings': {
        _keyDashboardView: prefs.getString(_keyDashboardView) ?? 'Weekly',
        _keyStartOfWeek: prefs.getString(_keyStartOfWeek) ?? 'Monday',
      },
      'categories': initialCategories.map((c) => c.toJson()).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };

    final jsonString = jsonEncode(exportData);
    final jsonBytes = utf8.encode(jsonString);

    final archive = Archive();
    archive.addFile(ArchiveFile('backup.json', jsonBytes.length, jsonBytes));
    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);

    String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Save Backup',
      fileName: 'budget_backup.zip',
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsBytes(zipBytes);
    } else {
      throw Exception('Backup cancelled');
    }
  }

  static Future<void> restoreFromZip() async {
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final zipBytes = await file.readAsBytes();

      final archive = ZipDecoder().decodeBytes(zipBytes);

      final jsonFile = archive.findFile('backup.json');
      if (jsonFile == null) {
        throw Exception('backup.json not found in the selected zip file.');
      }

      final jsonContent = utf8.decode(jsonFile.content as List<int>);
      final Map<String, dynamic> data = jsonDecode(jsonContent);

      if (data.containsKey('settings')) {
        final settings = data['settings'] as Map<String, dynamic>;
        final prefs = await SharedPreferences.getInstance();
        if (settings.containsKey(_keyDashboardView)) {
          await prefs.setString(_keyDashboardView, settings[_keyDashboardView]);
        }
        if (settings.containsKey(_keyStartOfWeek)) {
          await prefs.setString(_keyStartOfWeek, settings[_keyStartOfWeek]);
        }
      }

      // Restoring categories isn't supported yet as we use a static list
      if (data.containsKey('categories')) {
        // Here we would deserialize categories and update the app's state if we used state management
        // print('Categories data found: ${data['categories'].length} items');
      }

      if (data.containsKey('transactions')) {
        final List<dynamic> txList = data['transactions'];
        final List<Transaction> transactions = txList.map((json) => Transaction.fromJson(json as Map<String, dynamic>)).toList();
        await saveTransactions(transactions);
      }

    } else {
      throw Exception('Restore cancelled');
    }
  }
}
