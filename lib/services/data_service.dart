import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class DataService {
  static const String _keyDashboardView = 'dashboard_view';
  static const String _keyStartOfWeek = 'start_of_week';

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

    final Map<String, dynamic> exportData = {
      'settings': {
        _keyDashboardView: prefs.getString(_keyDashboardView) ?? 'Weekly',
        _keyStartOfWeek: prefs.getString(_keyStartOfWeek) ?? 'Monday',
      },
      'categories': initialCategories.map((c) => c.toJson()).toList(),
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

    } else {
      throw Exception('Restore cancelled');
    }
  }
}
