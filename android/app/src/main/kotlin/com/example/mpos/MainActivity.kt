package com.example.mpos

import android.os.Environment
import androidx.annotation.NonNull  // Ensure this is imported
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.mpos/downloads"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.mpos/downloads").setMethodCallHandler { call, result ->
            if (call.method == "getDownloadsDir") {
                val downloadsPath = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).path
                result.success(downloadsPath)
            } else {
                result.notImplemented()
            }
        }
    }
}
