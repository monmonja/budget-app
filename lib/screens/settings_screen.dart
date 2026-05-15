import 'package:flutter/material.dart';
import '../services/data_service.dart';
import 'category_rules_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _dashboardView = 'Weekly';
  String _startOfWeek = 'Monday';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final view = await DataService.getDashboardView();
    final start = await DataService.getStartOfWeek();
    setState(() {
      _dashboardView = view;
      _startOfWeek = start;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await DataService.saveDashboardView(_dashboardView);
    await DataService.saveStartOfWeek(_startOfWeek);
  }

  Future<void> _handleBackup() async {
    try {
      await DataService.exportToZip();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  Future<void> _handleRestore() async {
    try {
      await DataService.restoreFromZip();
      await _loadSettings(); // Reload settings after restore
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore successful!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Dashboard View'),
            trailing: DropdownButton<String>(
              value: _dashboardView,
              items: ['Weekly', 'Fortnightly', 'Monthly']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _dashboardView = value);
                  _saveSettings();
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Start of Week'),
            trailing: DropdownButton<String>(
              value: _startOfWeek,
              items: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _startOfWeek = value);
                  _saveSettings();
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Manage Category Rules'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryRulesScreen()),
              );
            },
          ),
          const Divider(),
          const Text(
            'Data Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _handleBackup,
            icon: const Icon(Icons.download),
            label: const Text('Backup to ZIP'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _handleRestore,
            icon: const Icon(Icons.upload),
            label: const Text('Restore from ZIP'),
          ),
        ],
      ),
    );
  }
}
