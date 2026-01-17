package com.incontrollo.parental_control_v2

import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView

class BlockScreenActivity : Activity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Mostra sopra tutte le altre app
        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        
        // Layout semplice
        setContentView(createBlockLayout())
    }
    
    private fun createBlockLayout(): android.view.View {
        val layout = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            gravity = android.view.Gravity.CENTER
            setBackgroundColor(android.graphics.Color.parseColor("#F44336"))
            setPadding(50, 50, 50, 50)
        }
        
        val blockedPackage = intent.getStringExtra("blocked_package") ?: ""
        val appName = getAppName(blockedPackage)
        
        // Icona
        val icon = ImageView(this).apply {
            setImageResource(android.R.drawable.ic_delete)
            layoutParams = android.widget.LinearLayout.LayoutParams(200, 200)
        }
        
        // Titolo
        val title = TextView(this).apply {
            text = "App Bloccata"
            textSize = 28f
            setTextColor(android.graphics.Color.WHITE)
            gravity = android.view.Gravity.CENTER
            setPadding(0, 40, 0, 20)
        }
        
        // Messaggio
        val message = TextView(this).apply {
            text = "$appName è stata bloccata dal controllo parentale"
            textSize = 18f
            setTextColor(android.graphics.Color.WHITE)
            gravity = android.view.Gravity.CENTER
            setPadding(0, 0, 0, 40)
        }
        
        // Pulsante chiudi
        val closeButton = Button(this).apply {
            text = "Torna Indietro"
            textSize = 18f
            setOnClickListener {
                goHome()
            }
        }
        
        layout.addView(icon)
        layout.addView(title)
        layout.addView(message)
        layout.addView(closeButton)
        
        return layout
    }
    
    private fun getAppName(packageName: String): String {
        return try {
            val pm = packageManager
            val appInfo = pm.getApplicationInfo(packageName, 0)
            pm.getApplicationLabel(appInfo).toString()
        } catch (e: PackageManager.NameNotFoundException) {
            packageName
        }
    }
    
    private fun goHome() {
        val intent = android.content.Intent(android.content.Intent.ACTION_MAIN).apply {
            addCategory(android.content.Intent.CATEGORY_HOME)
            flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(intent)
        finish()
    }
    
    override fun onBackPressed() {
        // Blocca il tasto back
        goHome()
    }
}
