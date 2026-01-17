package com.incontrollo.parental_control_v2

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.MethodChannel

class AppMonitorService : AccessibilityService() {
    
    companion object {
        var blockedApps = mutableSetOf<String>()
        var methodChannel: MethodChannel? = null
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return
            
            // Ignora la nostra app
            if (packageName == "com.incontrollo.parental_control_v2") {
                return
            }
            
            // Se l'app è bloccata, mostra schermata di blocco
            if (blockedApps.contains(packageName)) {
                showBlockScreen(packageName)
            }
        }
    }

    private fun showBlockScreen(packageName: String) {
        val intent = Intent(this, BlockScreenActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            putExtra("blocked_package", packageName)
        }
        startActivity(intent)
    }

    override fun onInterrupt() {
        // Chiamato quando il servizio viene interrotto
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        // Servizio accessibilità connesso
        
        // Gestisci il click sul pulsante di accessibilità
        accessibilityButtonController?.registerAccessibilityButtonCallback(
            object : android.accessibilityservice.AccessibilityButtonController.AccessibilityButtonCallback() {
                override fun onClicked(controller: android.accessibilityservice.AccessibilityButtonController?) {
                    openApp()
                }
                
                override fun onAvailabilityChanged(
                    controller: android.accessibilityservice.AccessibilityButtonController?,
                    available: Boolean
                ) {
                    // Il pulsante è disponibile o meno
                }
            }
        )
    }
    
    private fun openApp() {
        val intent = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        }
        startActivity(intent)
    }
}
