package com.incontrollo.parental_control_v2

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class UninstallProtectionActivity : FlutterActivity() {
    private val CHANNEL = "com.incontrollo.parental_control_v2/uninstall_protection"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "disableAdmin" -> {
                    val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                    val compName = ComponentName(this, AdminReceiver::class.java)
                    devicePolicyManager.removeActiveAdmin(compName)
                    result.success(true)
                    finish()
                }
                else -> result.notImplemented()
            }
        }
    }
}
