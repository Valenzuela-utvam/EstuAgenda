package com.example.estu_agenda.wearable

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import org.json.JSONArray
import org.json.JSONException

class TaskReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            context.checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            return
        }

        val manager = context.getSystemService(NotificationManager::class.java)
        manager.createNotificationChannel(
            NotificationChannel(
                CHANNEL_ID,
                "Recordatorios de tareas",
                NotificationManager.IMPORTANCE_HIGH,
            ),
        )

        val title = intent.getStringExtra(EXTRA_TITLE) ?: return
        val subject = intent.getStringExtra(EXTRA_SUBJECT).orEmpty()
        val notification = Notification.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle("Entrega próxima")
            .setContentText(if (subject.isEmpty()) title else "$title · $subject")
            .setCategory(Notification.CATEGORY_REMINDER)
            .setVisibility(Notification.VISIBILITY_PRIVATE)
            .setAutoCancel(true)
            .build()

        manager.notify(intent.getStringExtra(EXTRA_TASK_ID).orEmpty().hashCode(), notification)
    }

    companion object {
        const val CHANNEL_ID = "task_reminders"
        const val EXTRA_TASK_ID = "task_id"
        const val EXTRA_TITLE = "title"
        const val EXTRA_SUBJECT = "subject"
    }
}

internal object TaskReminderScheduler {
    private const val KEY_SCHEDULED_IDS = "scheduled_reminder_ids"

    private data class ScheduledTask(
        val id: String,
        val title: String,
        val subject: String,
        val dueAt: Long,
        val remindAt: Long,
    )

    fun schedule(context: Context, tasks: JSONArray) {
        val preferences = context.getSharedPreferences(
            WearableDataListenerService.PREFERENCES,
            Context.MODE_PRIVATE,
        )
        val alarmManager = context.getSystemService(AlarmManager::class.java)
        val validTasks = try {
            List(tasks.length()) { index ->
                val task = tasks.getJSONObject(index)
                ScheduledTask(
                    id = task.getString("id"),
                    title = task.getString("title"),
                    subject = task.getString("subject"),
                    dueAt = task.getLong("dueAt"),
                    remindAt = task.getLong("remindAt"),
                )
            }
        } catch (error: JSONException) {
            throw IllegalArgumentException(
                "Una tarea sincronizada tiene datos inválidos.",
                error,
            )
        }

        cancelExisting(context, alarmManager, preferences)
        val scheduledIds = mutableSetOf<String>()
        val now = System.currentTimeMillis()
        for (task in validTasks) {
            if (task.dueAt <= now) continue
            val reminderAt = task.remindAt.coerceAtLeast(now)

            val reminderIntent = Intent(context, TaskReminderReceiver::class.java).apply {
                data = Uri.parse("estuagenda://reminders/${task.id}")
                putExtra(TaskReminderReceiver.EXTRA_TASK_ID, task.id)
                putExtra(TaskReminderReceiver.EXTRA_TITLE, task.title)
                putExtra(TaskReminderReceiver.EXTRA_SUBJECT, task.subject)
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                reminderIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                !alarmManager.canScheduleExactAlarms()
            ) {
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    reminderAt,
                    pendingIntent,
                )
            } else {
                try {
                    alarmManager.setExactAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        reminderAt,
                        pendingIntent,
                    )
                } catch (_: SecurityException) {
                    alarmManager.setAndAllowWhileIdle(
                        AlarmManager.RTC_WAKEUP,
                        reminderAt,
                        pendingIntent,
                    )
                }
            }
            scheduledIds.add(task.id)
        }

        preferences.edit().putStringSet(KEY_SCHEDULED_IDS, scheduledIds).apply()
    }

    fun cancelAll(context: Context) {
        val preferences = context.getSharedPreferences(
            WearableDataListenerService.PREFERENCES,
            Context.MODE_PRIVATE,
        )
        cancelExisting(
            context,
            context.getSystemService(AlarmManager::class.java),
            preferences,
        )
    }

    private fun cancelExisting(
        context: Context,
        alarmManager: AlarmManager,
        preferences: android.content.SharedPreferences,
    ) {
        val oldIds = preferences.getStringSet(KEY_SCHEDULED_IDS, emptySet()).orEmpty()
        oldIds.forEach { taskId ->
            val reminderIntent = Intent(context, TaskReminderReceiver::class.java).apply {
                data = Uri.parse("estuagenda://reminders/$taskId")
            }
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                reminderIntent,
                PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE,
            )
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
            }
        }
        preferences.edit().remove(KEY_SCHEDULED_IDS).apply()
    }
}

class TaskBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        val preferences = context.getSharedPreferences(
            WearableDataListenerService.PREFERENCES,
            Context.MODE_PRIVATE,
        )
        if (!preferences.getBoolean(WearableDataListenerService.KEY_SIGNED_IN, false)) return

        val tasks = preferences.getString(WearableDataListenerService.KEY_TASKS, null) ?: return
        try {
            TaskReminderScheduler.schedule(context, JSONArray(tasks))
        } catch (error: JSONException) {
            android.util.Log.e("EstuAgendaWear", "No se pudieron restaurar los recordatorios.", error)
        } catch (error: IllegalArgumentException) {
            android.util.Log.e("EstuAgendaWear", "La lista local de tareas no es válida.", error)
        } catch (error: SecurityException) {
            android.util.Log.e("EstuAgendaWear", "No se pudieron restaurar los recordatorios.", error)
        }
    }
}
