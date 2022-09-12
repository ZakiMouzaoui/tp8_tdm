package com.example.test_project

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.media.MediaPlayer
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
                "com.tp8/music").setMethodCallHandler { call, result ->
            if (call.method == "startService") {
                //startMusicService(call.argument<String>("uri").toString())
                    val player = MediaPlayer.create(this, call.argument("uri"))
                player.start()
                result.success("ok")
            }
            if (call.method == "stopService") {
                //stopService()
                result.success("OK")
            }
        }
    }

    private fun startMusicService(uri : String) {
        val check = ActivityCompat.checkSelfPermission(this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE)
        if (check != PackageManager.PERMISSION_GRANTED) {

            requestPermissions(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), 1024)
        }
        startService(Intent(applicationContext, MusicService(uri)::class.java))
    }
}
