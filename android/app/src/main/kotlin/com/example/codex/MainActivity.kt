package com.debtdestroyer.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "debt_destroyer/play_integrity"
        ).setMethodCallHandler { call, result ->
            if (call.method != "requestIntegrityToken") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val installId = call.argument<String>("installId") ?: ""
            val nonce = call.argument<String>("nonce") ?: ""
            result.success("debug-attestation:$installId:$nonce")
        }
    }
}
