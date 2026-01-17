package com.incontrollo.parental_control_v2

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.incontrollo.parental_control_v2/device_admin"
    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var adminComponent: ComponentName

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        adminComponent = ComponentName(this, AdminReceiver::class.java)
        
        AppMonitorService.methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val apps = getInstalledApplications()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("ERROR", "Errore nel recupero app: ${e.message}", null)
                    }
                }
                "blockApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        AppMonitorService.blockedApps.add(packageName)
                        saveBlockedApps()
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "packageName non fornito", null)
                    }
                }
                "unblockApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        AppMonitorService.blockedApps.remove(packageName)
                        saveBlockedApps()
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "packageName non fornito", null)
                    }
                }
                "isAccessibilityEnabled" -> {
                    val isEnabled = isAccessibilityServiceEnabled()
                    result.success(isEnabled)
                }
                "requestAccessibilityPermission" -> {
                    openAccessibilitySettings()
                    result.success(null)
                }
                "isAdminActive" -> {
                    val isActive = devicePolicyManager.isAdminActive(adminComponent)
                    result.success(isActive)
                }
                "requestAdminPermission" -> {
                    requestAdminPrivileges()
                    result.success(null)
                }
                "getBlockedApps" -> {
                    result.success(AppMonitorService.blockedApps.toList())
                }
                "isOverlayPermissionGranted" -> {
                    val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else {
                        true
                    }
                    result.success(granted)
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(null)
                }
                "reloadBlockedApps" -> {
                    // Ricarica le app bloccate nel servizio
                    val prefs = getSharedPreferences("parental_control", Context.MODE_PRIVATE)
                    val saved = prefs.getStringSet("blocked_apps", emptySet()) ?: emptySet()
                    AppMonitorService.blockedApps.clear()
                    AppMonitorService.blockedApps.addAll(saved)
                    android.util.Log.d("MainActivity", "App bloccate ricaricate: ${AppMonitorService.blockedApps.size}")
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
        
        // Carica app bloccate salvate
        loadBlockedApps()
    }

    private fun getInstalledApplications(): List<Map<String, Any>> {
        val packageManager = packageManager
        val apps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
        
        // Mostra TUTTE le app (utente + sistema)
        return apps.map { app ->
            mapOf(
                "packageName" to app.packageName,
                "appName" to packageManager.getApplicationLabel(app).toString(),
                "isBlocked" to AppMonitorService.blockedApps.contains(app.packageName)
            )
        }
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val service = ComponentName(this, AppMonitorService::class.java)
        val enabledServicesSetting = Settings.Secure.getString(
            contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        ) ?: return false
        
        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)
        
        while (colonSplitter.hasNext()) {
            val componentNameString = colonSplitter.next()
            val enabledService = ComponentName.unflattenFromString(componentNameString)
            if (enabledService != null && enabledService == service) {
                return true
            }
        }
        return false
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun requestAdminPrivileges() {
        val intent = Intent(android.app.admin.DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
        intent.putExtra(android.app.admin.DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
        intent.putExtra(
            android.app.admin.DevicePolicyManager.EXTRA_ADD_EXPLANATION,
            "Attiva la protezione per impedire la disinstallazione non autorizzata dell'app"
        )
        startActivityForResult(intent, 1)
    }

    private fun saveBlockedApps() {
        val prefs = getSharedPreferences("parental_control", Context.MODE_PRIVATE)
        val success = prefs.edit().putStringSet("blocked_apps", AppMonitorService.blockedApps).commit()
        android.util.Log.d("MainActivity", "App bloccate salvate: $success, Totale: ${AppMonitorService.blockedApps.size}")
    }

    private fun loadBlockedApps() {
        val prefs = getSharedPreferences("parental_control", Context.MODE_PRIVATE)
        val saved = prefs.getStringSet("blocked_apps", emptySet()) ?: emptySet()
        AppMonitorService.blockedApps.addAll(saved)
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                )
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
            }
        }
    }
}
