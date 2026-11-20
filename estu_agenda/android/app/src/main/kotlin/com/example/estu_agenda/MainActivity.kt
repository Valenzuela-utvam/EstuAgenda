package com.example.estu_agenda

import com.google.android.gms.wearable.PutDataRequest
import com.google.android.gms.wearable.Wearable
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "estuagenda/wearable",
        ).setMethodCallHandler { call, result ->
            if (call.method != "syncUpcomingTasks") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val payload = call.argument<String>("payload")
            if (payload == null) {
                result.error("invalid_payload", "Falta el contenido para sincronizar.", null)
                return@setMethodCallHandler
            }

            val request = PutDataRequest.create("/estuagenda/upcoming-tasks")
                .setData(payload.toByteArray(Charsets.UTF_8))
                .setUrgent()

            Wearable.getDataClient(this)
                .putDataItem(request)
                .addOnSuccessListener { result.success(null) }
                .addOnFailureListener { error ->
                    result.error("wear_sync_failed", error.message, null)
                }
        }
    }
}
