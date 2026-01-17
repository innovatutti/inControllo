import 'package:flutter/services.dart';

/// Servizio per la gestione del controllo app tramite Platform Channels
class DeviceAdminService {
  static const platform = MethodChannel('com.incontrollo.parental_control_v2/device_admin');

  /// Ottiene lista di tutte le app installate sul dispositivo
  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getInstalledApps');
      return result.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } on PlatformException catch (e) {
      print("Errore nel recupero delle app: ${e.message}");
      return [];
    }
  }

  /// Blocca un'app specificata dal packageName
  /// 
  /// [packageName] il package name dell'app da bloccare (es: com.whatsapp)
  /// Ritorna true se l'operazione è riuscita
  Future<bool> blockApp(String packageName) async {
    try {
      final bool result = await platform.invokeMethod('blockApp', {
        'packageName': packageName,
      });
      return result;
    } on PlatformException catch (e) {
      print("Errore nel blocco dell'app: ${e.message}");
      return false;
    }
  }

  /// Sblocca un'app precedentemente bloccata
  /// 
  /// [packageName] il package name dell'app da sbloccare
  /// Ritorna true se l'operazione è riuscita
  Future<bool> unblockApp(String packageName) async {
    try {
      final bool result = await platform.invokeMethod('unblockApp', {
        'packageName': packageName,
      });
      return result;
    } on PlatformException catch (e) {
      print("Errore nello sblocco dell'app: ${e.message}");
      return false;
    }
  }

  /// Verifica se il servizio di accessibilità è attivo
  Future<bool> isAccessibilityEnabled() async {
    try {
      final bool result = await platform.invokeMethod('isAccessibilityEnabled');
      return result;
    } on PlatformException catch (e) {
      print("Errore nella verifica accessibilità: ${e.message}");
      return false;
    }
  }

  /// Apre le impostazioni di accessibilità
  Future<void> requestAccessibilityPermission() async {
    try {
      await platform.invokeMethod('requestAccessibilityPermission');
    } on PlatformException catch (e) {
      print("Errore nell'apertura impostazioni: ${e.message}");
    }
  }

  /// Ottiene la lista delle app bloccate
  Future<List<String>> getBlockedApps() async {
    try {
      final List<dynamic> result = await platform.invokeMethod('getBlockedApps');
      return result.cast<String>();
    } on PlatformException catch (e) {
      print("Errore nel recupero app bloccate: ${e.message}");
      return [];
    }
  }

  /// Verifica se l'app ha protezione admin attiva
  Future<bool> isAdminActive() async {
    try {
      final bool result = await platform.invokeMethod('isAdminActive');
      return result;
    } on PlatformException catch (e) {
      print("Errore verifica admin: ${e.message}");
      return false;
    }
  }

  /// Richiede permessi admin per protezione disinstallazione
  Future<void> requestAdminPermission() async {
    try {
      await platform.invokeMethod('requestAdminPermission');
    } on PlatformException catch (e) {
      print("Errore richiesta admin: ${e.message}");
    }
  }

  /// Verifica se il permesso overlay è concesso
  Future<bool> isOverlayPermissionGranted() async {
    try {
      final bool result = await platform.invokeMethod('isOverlayPermissionGranted');
      return result;
    } on PlatformException catch (e) {
      print("Errore verifica overlay: ${e.message}");
      return false;
    }
  }

  /// Richiede il permesso overlay (mostra sopra altre app)
  Future<void> requestOverlayPermission() async {
    try {
      await platform.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (e) {
      print("Errore richiesta overlay: ${e.message}");
    }
  }

  /// Forza il ricaricamento delle app bloccate nel servizio
  Future<void> reloadBlockedApps() async {
    try {
      await platform.invokeMethod('reloadBlockedApps');
    } on PlatformException catch (e) {
      print("Errore reload app bloccate: ${e.message}");
    }
  }
}
