package com.incontrollo.parental_control_v2

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast

class AdminReceiver : DeviceAdminReceiver() {
    
    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        Toast.makeText(context, "Protezione attivata", Toast.LENGTH_SHORT).show()
    }

    override fun onDisableRequested(context: Context, intent: Intent): CharSequence {
        // Quando l'utente prova a disattivare l'admin (per disinstallare l'app)
        // Avvia l'activity di verifica PIN
        val pinIntent = Intent(context, UninstallProtectionActivity::class.java)
        pinIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(pinIntent)
        
        return "Per disattivare la protezione, inserisci il PIN"
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        Toast.makeText(context, "Protezione disattivata", Toast.LENGTH_SHORT).show()
    }
}
