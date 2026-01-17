package com.incontrollo.parental_control_v2

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log

class ShortcutActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Log.d("ShortcutActivity", "Shortcut clicked, opening MainActivity")
        
        // Crea intent per aprire la MainActivity
        val intent = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_MAIN
            addCategory(Intent.CATEGORY_LAUNCHER)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or 
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or 
                    Intent.FLAG_ACTIVITY_SINGLE_TOP or
                    Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        }
        
        startActivity(intent)
        finish()
    }
}
