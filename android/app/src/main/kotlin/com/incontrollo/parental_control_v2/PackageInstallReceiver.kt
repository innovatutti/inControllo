package com.incontrollo.parental_control_v2

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class PackageInstallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_PACKAGE_ADDED -> {
                val packageName = intent.data?.schemeSpecificPart
                if (packageName != null && packageName != context.packageName) {
                    // Una nuova app è stata installata
                    // Avvia activity per verifica PIN
                    val pinIntent = Intent(context, InstallVerificationActivity::class.java)
                    pinIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    pinIntent.putExtra("packageName", packageName)
                    context.startActivity(pinIntent)
                }
            }
        }
    }
}
