package com.debtdestroyer.app

import java.nio.charset.StandardCharsets
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec
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
            val debugSecret = call.argument<String>("debugSecret")
            if (!debugSecret.isNullOrBlank()) {
                val payload = "$installId:$nonce"
                val mac = Mac.getInstance("HmacSHA256")
                mac.init(SecretKeySpec(debugSecret.toByteArray(StandardCharsets.UTF_8), "HmacSHA256"))
                val signature = mac.doFinal(payload.toByteArray(StandardCharsets.UTF_8))
                    .joinToString("") { byte -> "%02x".format(byte) }
                result.success("debug-attestation:v1:$signature")
                return@setMethodCallHandler
            }
            result.error("attestation_unavailable", "No debug attestation secret configured.", null)
        }
    }
}
