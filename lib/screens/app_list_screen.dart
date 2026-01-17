import 'package:flutter/material.dart';
import 'package:parental_control/services/device_admin_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  final DeviceAdminService _deviceAdminService = DeviceAdminService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _installedApps = [];
  List<Map<String, dynamic>> _filteredApps = [];
  Set<String> _blockedApps = {}; // Lista app bloccate
  bool _isLoading = true;
  bool _isAccessibilityEnabled = false;
  bool _isAdminActive = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBlockedApps();
    _checkAccessibilityStatus();
    _checkAdminStatus();
    _loadApps();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    final isActive = await _deviceAdminService.isAdminActive();
    setState(() {
      _isAdminActive = isActive;
    });
  }

  Future<void> _loadBlockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    final blocked = prefs.getStringList('blocked_apps') ?? [];
    setState(() {
      _blockedApps = blocked.toSet();
    });
  }

  Future<void> _saveBlockedApps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blocked_apps', _blockedApps.toList());
  }

  Future<void> _checkAccessibilityStatus() async {
    final isEnabled = await _deviceAdminService.isAccessibilityEnabled();
    setState(() {
      _isAccessibilityEnabled = isEnabled;
    });
  }

  Future<void> _loadApps() async {
    setState(() {
      _isLoading = true;
    });
    
    final apps = await _deviceAdminService.getInstalledApps();
    
    setState(() {
      _installedApps = apps;
      _filteredApps = apps;
      _isLoading = false;
    });
  }

  void _filterApps(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredApps = _installedApps;
      } else {
        _filteredApps = _installedApps.where((app) {
          final appName = app['appName']?.toString().toLowerCase() ?? '';
          final packageName = app['packageName']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return appName.contains(searchLower) || packageName.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _toggleAppStatus(String packageName, bool currentlyBlocked) async {
    // Verifica prima se abbiamo i permessi
    if (!_isAccessibilityEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devi prima attivare il servizio di accessibilità'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    bool success;
    if (currentlyBlocked) {
      success = await _deviceAdminService.unblockApp(packageName);
      if (success) {
        setState(() {
          _blockedApps.remove(packageName);
        });
        await _saveBlockedApps();
      }
    } else {
      success = await _deviceAdminService.blockApp(packageName);
      if (success) {
        setState(() {
          _blockedApps.add(packageName);
        });
        await _saveBlockedApps();
      }
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentlyBlocked ? 'App sbloccata' : 'App bloccata'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore nell\'operazione. Riprova.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('inControllo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApps,
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_isAdminActive)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade100,
              child: Column(
                children: [
                  const Icon(
                    Icons.security,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Protezione disinstallazione',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Attiva la protezione per richiedere il PIN prima di disinstallare l\'app',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _deviceAdminService.requestAdminPermission();
                      Future.delayed(const Duration(seconds: 1), _checkAdminStatus);
                    },
                    icon: const Icon(Icons.shield),
                    label: const Text('Attiva protezione'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          if (!_isAccessibilityEnabled)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.orange.shade100,
              child: Column(
                children: [
                  const Icon(
                    Icons.accessibility_new,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Servizio di accessibilità richiesto',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Per bloccare le app, attiva il servizio "Parental Control" nelle impostazioni di accessibilità',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _deviceAdminService.requestAccessibilityPermission();
                      Future.delayed(const Duration(seconds: 2), _checkAccessibilityStatus);
                    },
                    icon: const Icon(Icons.settings_accessibility),
                    label: const Text('Apri impostazioni'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterApps,
              decoration: InputDecoration(
                hintText: 'Cerca app...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterApps('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApps.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'Nessuna app trovata per "$_searchQuery"'
                              : 'Nessuna app trovata',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredApps.length,
                        itemBuilder: (context, index) {
                          final app = _filteredApps[index];
                          final packageName = app['packageName'] as String;
                          final appName = app['appName'] as String;
                          final isBlocked = _blockedApps.contains(packageName);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.android),
                              ),
                              title: Text(
                                appName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                packageName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: Switch(
                                value: !isBlocked,
                                onChanged: _isAccessibilityEnabled
                                    ? (value) {
                                        _toggleAppStatus(packageName, isBlocked);
                                      }
                                    : null,
                                activeColor: Colors.green,
                                inactiveTrackColor: Colors.red.shade200,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
