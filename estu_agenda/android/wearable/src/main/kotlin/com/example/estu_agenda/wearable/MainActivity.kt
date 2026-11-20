package com.example.estu_agenda.wearable

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import org.json.JSONArray
import org.json.JSONException
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : Activity() {
    private val preferences by lazy {
        getSharedPreferences(WearableDataListenerService.PREFERENCES, MODE_PRIVATE)
    }
    private val preferenceListener =
        android.content.SharedPreferences.OnSharedPreferenceChangeListener { _, _ ->
            runOnUiThread { renderTasks() }
        }
    private lateinit var taskList: LinearLayout
    private lateinit var taskCount: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(createContent())
        requestNotificationPermission()
        renderTasks()
    }

    override fun onResume() {
        super.onResume()
        preferences.registerOnSharedPreferenceChangeListener(preferenceListener)
        renderTasks()
    }

    override fun onPause() {
        preferences.unregisterOnSharedPreferenceChangeListener(preferenceListener)
        super.onPause()
    }

    private fun createContent(): android.view.View {
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(18), dp(18), dp(18), dp(12))
            setBackgroundColor(Color.rgb(235, 246, 248))
        }
        val header = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(8), dp(2), dp(8), dp(14))
        }
        val heading = TextView(this).apply {
            text = "EsTuAgenda"
            textSize = 20f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.rgb(29, 150, 159))
            gravity = Gravity.CENTER
        }
        taskCount = TextView(this).apply {
            text = "Actividades sincronizadas"
            textSize = 12f
            setTextColor(Color.rgb(18, 75, 81))
            gravity = Gravity.CENTER
        }
        header.addView(heading)
        header.addView(taskCount)
        root.addView(
            header,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ),
        )
        taskList = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
        }
        val scrollView = ScrollView(this).apply {
            isFillViewport = true
            clipToPadding = false
            addView(
                taskList,
                ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                ),
            )
        }
        root.addView(
            scrollView,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                0,
                1f,
            ),
        )
        return root
    }

    private fun renderTasks() {
        if (!::taskList.isInitialized) return
        taskList.removeAllViews()
        if (!preferences.getBoolean(WearableDataListenerService.KEY_SIGNED_IN, false)) {
            addMessage("Inicia sesión en tu teléfono para sincronizar tus tareas.")
            return
        }

        val tasksJson = preferences.getString(WearableDataListenerService.KEY_TASKS, null)
        if (tasksJson == null) {
            addMessage("Abre EsTuAgenda en tu teléfono para sincronizar.")
            return
        }

        try {
            val tasks = JSONArray(tasksJson)
            if (tasks.length() == 0) {
                taskCount.text = "0 actividades"
                addMessage("No tienes tareas pendientes.")
                return
            }
            taskCount.text = if (tasks.length() == 1) {
                "1 actividad"
            } else {
                "${tasks.length()} actividades"
            }
            for (index in 0 until tasks.length()) {
                val task = tasks.getJSONObject(index)
                addTaskCard(
                    title = task.getString("title"),
                    subject = task.getString("subject"),
                    status = task.optString("status", "pendiente"),
                    dueAt = task.optLong("dueAt").takeIf { it > 0L },
                )
            }
        } catch (error: JSONException) {
            addMessage("No se pudieron leer las tareas sincronizadas.")
            android.util.Log.e("EstuAgendaWear", "Los datos sincronizados no son válidos.", error)
        }
    }

    private fun addMessage(message: String) {
        taskList.addView(
            TextView(this).apply {
                text = message
                textSize = 14f
                setTextColor(Color.rgb(18, 75, 81))
                gravity = Gravity.CENTER
                setPadding(dp(12), dp(20), dp(12), dp(20))
            },
        )
    }

    private fun addTaskCard(title: String, subject: String, status: String, dueAt: Long?) {
        val statusColor = when (status) {
            "enProceso" -> Color.rgb(255, 183, 77)
            "calendar" -> Color.rgb(29, 150, 159)
            else -> Color.rgb(229, 115, 115)
        }
        val deadline = dueAt?.let {
            val date = SimpleDateFormat(
                "EEE d MMM · HH:mm",
                Locale.getDefault(),
            ).format(Date(it))
            if (it < System.currentTimeMillis()) "Vencida · $date" else "Entrega · $date"
        } ?: "Sin fecha de entrega"
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding(dp(12), dp(11), dp(12), dp(11))
            background = roundedBackground(
                fill = Color.WHITE,
                stroke = Color.rgb(204, 230, 232),
                radius = dp(14).toFloat(),
            )
        }
        val statusDot = View(this).apply {
            background = roundedBackground(statusColor, statusColor, dp(12).toFloat())
        }
        card.addView(
            statusDot,
            LinearLayout.LayoutParams(dp(10), dp(10)).apply {
                marginEnd = dp(10)
            },
        )
        val details = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
        }
        details.addView(TextView(this).apply {
            text = title
            textSize = 14f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(Color.rgb(18, 75, 81))
            maxLines = 2
        })
        details.addView(TextView(this).apply {
            text = subject
            textSize = 11f
            setTextColor(Color.rgb(29, 150, 159))
            maxLines = 1
        })
        details.addView(TextView(this).apply {
            text = deadline
            textSize = 11f
            setTextColor(Color.rgb(95, 116, 119))
            maxLines = 1
        })
        card.addView(
            details,
            LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f),
        )
        taskList.addView(
            card,
            LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT,
            ).apply {
                bottomMargin = dp(8)
                marginStart = dp(2)
                marginEnd = dp(2)
            },
        )
    }

    private fun roundedBackground(fill: Int, stroke: Int, radius: Float) =
        GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(fill)
            setStroke(dp(1), stroke)
            cornerRadius = radius
        }

    private fun dp(value: Int): Int =
        (value * resources.displayMetrics.density).toInt()

    private fun requestNotificationPermission() {
        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 100)
        }
    }
}
