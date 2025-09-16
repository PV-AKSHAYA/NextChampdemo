package com.example.NextChamp

import com.example.NextChamp.UserApi
import com.example.NextChamp.UserApiImpl  // import your implementation

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Register Pigeon API implementation here:
        UserApi.setUp(flutterEngine.dartExecutor.binaryMessenger, UserApiImpl())
    }
}
