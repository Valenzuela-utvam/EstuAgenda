package com.example.estu_agenda.wearable

import android.util.Log
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.WearableListenerService
import org.json.JSONException
import org.json.JSONObject

class WearableDataListenerService : WearableListenerService() {
    override fun onDataChanged(dataEvents: DataEventBuffer) {
        dataEvents.forEach { event ->
            if (
                event.type != DataEvent.TYPE_CHANGED ||
                event.dataItem.uri.path != TASKS_PATH
            ) {
                return@forEach
            }

            try {
                val payload = JSONObject(
                    String(event.dataItem.data ?: return@forEach, Charsets.UTF_8),
                )
                val signedIn = payload.optBoolean("signedIn", false)
                val tasks = payload.optJSONArray("tasks") ?: return@forEach
                getSharedPreferences(PREFERENCES, MODE_PRIVATE)
                    .edit()
                    .putBoolean(KEY_SIGNED_IN, signedIn)
                    .putString(KEY_TASKS, tasks.toString())
                    .apply()

                if (signedIn) {
                    try {
                        TaskReminderScheduler.schedule(this, tasks)
                    } catch (error: IllegalArgumentException) {
                        Log.e(TAG, "No se pudieron programar los recordatorios.", error)
                    } catch (error: SecurityException) {
                        Log.e(TAG, "El sistema rechazó la programación de recordatorios.", error)
                    }
                } else {
                    TaskReminderScheduler.cancelAll(this)
                }
            } catch (error: JSONException) {
                Log.e(TAG, "No se pudo leer la sincronización de tareas.", error)
            }
        }
    }

    companion object {
        const val TASKS_PATH = "/estuagenda/upcoming-tasks"
        const val PREFERENCES = "estuagenda_wearable"
        const val KEY_SIGNED_IN = "signed_in"
        const val KEY_TASKS = "tasks"
        private const val TAG = "EstuAgendaWear"
    }
}
