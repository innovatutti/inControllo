import 'package:flutter/material.dart';
import 'package:parental_control/services/device_admin_service.dart';

class DiagnosticsScreen extends StatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final DeviceAdminService _service = DeviceAdminService();
  bool _isAccessibilityEnabled = false;
  bool _isAdminActive = false;
  bool _isOverlayPermissionGranted = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final accessibilityEnabled = await _service.isAccessibilityEnabled();
    final adminActive = await _service.isAdminActive();
    final overlayGranted = await _service.isOverlayPermissionGranted();
    
    setState(() {
      _isAccessibilityEnabled = accessibilityEnabled;
      _isAdminActive = adminActive;
      _isOverlayPermissionGranted = overlayGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _isAccessibilityEnabled && _isAdminActive && _isOverlayPermissionGranted;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostica'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (allGranted)
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 48),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Tutti i permessi sono attivi!\nL\'app funzionerà correttamente.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700, size: 48),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Alcuni permessi mancano.\nSegui le istruzioni sotto.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Stato Permessi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildPermissionCard(
            'Servizio di Accessibilità',
            'Necessario per bloccare le app',
            _isAccessibilityEnabled,
            () async {
              await _service.requestAccessibilityPermission();
              Future.delayed(const Duration(seconds: 2), _checkPermissions);
            },
            'Vai alle Impostazioni di Accessibilità',
          ),
          
          _buildPermissionCard(
            'Protezione Amministratore',
            'Impedisce la disinstallazione non autorizzata',
            _isAdminActive,
            () async {
              await _service.requestAdminPermission();
              Future.delayed(const Duration(seconds: 1), _checkPermissions);
            },
            'Attiva Amministratore',
          ),
          
          _buildPermissionCard(
            'Mostra sopra altre app',
            'Permette di mostrare la schermata di blocco',
            _isOverlayPermissionGranted,
            () async {
              await _service.requestOverlayPermission();
              Future.delayed(const Duration(seconds: 1), _checkPermissions);
            },
            'Attiva Overlay',
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          const Text(
            'Impostazioni MIUI/Xiaomi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildMIUIInstructionCard(
            'Autostart',
            'Permette all\'app di avviarsi automaticamente',
            'Impostazioni → App → Gestisci app → inControllo → Autostart → ATTIVA',
            Icons.power_settings_new,
          ),
          
          _buildMIUIInstructionCard(
            'Risparmio Batteria',
            'Impedisce al sistema di chiudere l\'app',
            'Impostazioni → Batteria → Risparmio energetico → inControllo → Nessuna restrizione',
            Icons.battery_charging_full,
          ),
          
          _buildMIUIInstructionCard(
            'App in Background',
            'Permette all\'app di funzionare in background',
            'Impostazioni → Batteria → App in background → inControllo → Nessuna restrizione',
            Icons.apps,
          ),
          
          _buildMIUIInstructionCard(
            'Tieni in Memoria',
            'Blocca l\'app nella lista recenti',
            'Apri Recenti → Tieni premuto sull\'app → Tocca l\'icona del lucchetto',
            Icons.lock,
          ),
          
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _checkPermissions,
            icon: const Icon(Icons.refresh),
            label: const Text('Aggiorna Stato'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionCard(
    String title,
    String description,
    bool isGranted,
    VoidCallback onTap,
    String buttonText,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isGranted ? Icons.check_circle : Icons.cancel,
          color: isGranted ? Colors.green : Colors.red,
          size: 32,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(description),
            if (!isGranted) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onTap,
                child: Text(buttonText),
              ),
            ],
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildMIUIInstructionCard(
    String title,
    String description,
    String instructions,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(description),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              instructions,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
