import 'package:flutter/material.dart';
import 'package:pos_desktop_loop/constants/app_colors.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedPrinterName;
  bool _isScanning = false;
  String _scanningStatus = 'Tap to scan for printers';
  List<BluetoothInfo> _availablePrinters = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPrinter();
  }

  Future<void> _loadSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPrinterName = prefs.getString('selectedBluetoothPrinterName');
    });
  }

  Future<void> _scanForPrinters() async {
    setState(() {
      _isScanning = true;
      _scanningStatus = 'Scanning for Bluetooth printers...';
      _availablePrinters.clear();
    });

    try {
      final List<BluetoothInfo> devices =
          await PrintBluetoothThermal.pairedBluetooths;

      setState(() {
        _availablePrinters = devices;
        _isScanning = false;
        _scanningStatus =
            devices.isEmpty
                ? 'No Bluetooth printers found'
                : 'Tap a printer to select';
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _scanningStatus = 'Scanning failed: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error scanning printers: $e')));
    }
  }

  Future<void> _savePrinter(BluetoothInfo? device) async {
    final prefs = await SharedPreferences.getInstance();
    if (device != null) {
      await prefs.setString('selectedBluetoothPrinterId', device.macAdress);
      await prefs.setString('selectedBluetoothPrinterName', device.name);
    }
    setState(() {
      _selectedPrinterName = device?.name;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          device != null
              ? 'Printer "${device.name}" saved!'
              : 'No printer selected.',
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
    bool showBorder = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration:
            showBorder
                ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                )
                : null,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppColors.primaryGreen,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      isDestructive ? FontWeight.bold : FontWeight.normal,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSetting(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Icon(Icons.dark_mode, color: AppColors.primaryGreen),
              const SizedBox(width: 16),
              const Text(
                'Theme Mode',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Column(
            children: [
              _buildThemeOption('Light', ThemeMode.light, themeProvider),
              _buildThemeOption('Dark', ThemeMode.dark, themeProvider),
              _buildThemeOption(
                'System Default',
                ThemeMode.system,
                themeProvider,
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade300, height: 1),
      ],
    );
  }

  Widget _buildThemeOption(
    String title,
    ThemeMode mode,
    ThemeProvider themeProvider,
  ) {
    return InkWell(
      onTap: () => themeProvider.updateThemeMode(mode),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              themeProvider.themeMode == mode
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color:
                  themeProvider.themeMode == mode
                      ? AppColors.primaryGreen
                      : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Printer Selection Section
              _buildSectionTitle("Printing"),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Receipt Printer (Bluetooth)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _isScanning ? null : _scanForPrinters,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedPrinterName ?? 'No printer selected',
                                style: TextStyle(
                                  color:
                                      _selectedPrinterName == null
                                          ? Colors.grey
                                          : Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              _isScanning
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.search),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _scanningStatus,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (_availablePrinters.isNotEmpty)
                        const SizedBox(height: 16),
                      if (_availablePrinters.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _availablePrinters.length,
                          itemBuilder: (context, index) {
                            final printer = _availablePrinters[index];
                            return ListTile(
                              title: Text(printer.name),
                              subtitle: Text(printer.macAdress),
                              onTap: () => _savePrinter(printer),
                              trailing:
                                  _selectedPrinterName == printer.name
                                      ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      )
                                      : null,
                            );
                          },
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap on a discovered printer to select and save it.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preferences Section
              _buildSectionTitle("Preferences"),
              _buildThemeModeSetting(context),

              // App Settings Section
              _buildSectionTitle("App Settings"),
              _buildSettingsItem(
                Icons.notifications,
                'Notifications Settings',
                () {},
              ),
              _buildSettingsItem(Icons.backup, 'Data Backup & Restore', () {}),
              _buildSettingsItem(Icons.support, 'Support & Contact', () {}),
              _buildSettingsItem(Icons.info, 'About', () {}, showBorder: false),
            ],
          ),
        ),
      ),
    );
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final String _themePreferenceKey = 'themePreference';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeMode = prefs.getString(_themePreferenceKey);

    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == themeMode,
      orElse: () => ThemeMode.system,
    );
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode newMode) async {
    _themeMode = newMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, newMode.toString());
  }
}
