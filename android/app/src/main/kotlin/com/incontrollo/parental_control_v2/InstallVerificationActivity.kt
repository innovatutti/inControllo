package com.incontrollo.parental_control_v2

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class InstallVerificationActivity : FlutterActivity() {
    private val CHANNEL = "com.incontrollo.parental_control_v2/install_verification"

    override fun getInitialRoute(): String {
        return "/install_verification"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val packageName = intent.getStringExtra("packageName") ?: ""
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getPackageName" -> {
                    result.success(packageName)
                }
                "allowInstall" -> {
                    // PIN corretto, permetti l'installazione
                    result.success(true)
                    finish()
                }
                "denyInstall" -> {
                    // PIN errato, blocca/disinstalla l'app
                    val pm = packageManager
                    try {
                        pm.getPackageInfo(packageName, 0)
                        // Se l'app è installata, prova a disinstallarla
                        val deleteIntent = pm.getLaunchIntentForPackage("com.android.packageinstaller")
                        deleteIntent?.data = android.net.Uri.parse("package:$packageName")
                        startActivity(deleteIntent)
                    } catch (e: Exception) {
                        // App non trovata
                    }
                    result.success(true)
                    finish()
                }
                else -> result.notImplemented()
            }
        }
    }
}
