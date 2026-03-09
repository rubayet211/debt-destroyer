package com.debtdestroyer.app

import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.charset.StandardCharsets
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

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
            val cloudProjectNumber = call.argument<String>("cloudProjectNumber")
            val debugSecret = call.argument<String>("debugSecret")

            if (!cloudProjectNumber.isNullOrBlank()) {
                requestPlayIntegrityToken(
                    nonce = nonce,
                    cloudProjectNumber = cloudProjectNumber,
                    onSuccess = { token ->
                        result.success(token)
                    },
                    onFailure = { errorCode, message ->
                        if (!debugSecret.isNullOrBlank()) {
                            result.success(buildDebugToken(installId, nonce, debugSecret))
                        } else {
                            result.error(errorCode, message, null)
                        }
                    }
                )
                return@setMethodCallHandler
            }

            if (!debugSecret.isNullOrBlank()) {
                result.success(buildDebugToken(installId, nonce, debugSecret))
                return@setMethodCallHandler
            }

            result.error(
                "attestation_unavailable",
                "No Play Integrity cloud project number or debug attestation secret configured.",
                null
            )
        }
    }

    private fun requestPlayIntegrityToken(
        nonce: String,
        cloudProjectNumber: String,
        onSuccess: (String) -> Unit,
        onFailure: (String, String) -> Unit
    ) {
        val projectNumber = cloudProjectNumber.toLongOrNull()
        if (projectNumber == null) {
            onFailure(
                "attestation_unavailable",
                "Play Integrity cloud project number is invalid."
            )
            return
        }

        val integrityManager = IntegrityManagerFactory.create(applicationContext)
        val request = IntegrityTokenRequest.builder()
            .setNonce(nonce)
            .setCloudProjectNumber(projectNumber)
            .build()

        integrityManager.requestIntegrityToken(request)
            .addOnSuccessListener { response ->
                val token = response.token()
                if (token.isNullOrBlank()) {
                    onFailure(
                        "attestation_unavailable",
                        "Play Integrity returned an empty token."
                    )
                } else {
                    onSuccess(token)
                }
            }
            .addOnFailureListener { error ->
                onFailure(
                    "attestation_unavailable",
                    error.message ?: "Play Integrity request failed."
                )
            }
    }

    private fun buildDebugToken(
        installId: String,
        nonce: String,
        debugSecret: String
    ): String {
        val payload = "$installId:$nonce"
        val mac = Mac.getInstance("HmacSHA256")
        mac.init(SecretKeySpec(debugSecret.toByteArray(StandardCharsets.UTF_8), "HmacSHA256"))
        val signature = mac.doFinal(payload.toByteArray(StandardCharsets.UTF_8))
            .joinToString("") { byte -> "%02x".format(byte) }
        return "debug-attestation:v1:$signature"
    }
}
