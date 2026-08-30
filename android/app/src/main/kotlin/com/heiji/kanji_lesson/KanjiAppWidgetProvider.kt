package com.heiji.kanji_lesson

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.io.File
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

class KanjiAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        scheduleDailyAlarm(context)
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            "TOGGLE_VIEW" -> {
                val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
                val currentView = prefs.getInt("current_view", 0)
                val nextView = if (currentView == 0) 1 else 0
                prefs.edit().putInt("current_view", nextView).apply()

                val appWidgetManager = AppWidgetManager.getInstance(context)
                val widgetIds = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, KanjiAppWidgetProvider::class.java)
                )
                for (id in widgetIds) {
                    updateAppWidget(context, appWidgetManager, id)
                }
            }
            "ROTATE_KANJI" -> {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val widgetIds = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, KanjiAppWidgetProvider::class.java)
                )
                for (id in widgetIds) {
                    updateAppWidget(context, appWidgetManager, id)
                }
            }
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        scheduleDailyAlarm(context)
    }

    private fun scheduleDailyAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, KanjiAppWidgetProvider::class.java).apply {
            action = "ROTATE_KANJI"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Fire at 00:05 daily
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 5)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            if (before(Calendar.getInstance())) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }

        alarmManager.setRepeating(
            AlarmManager.RTC_WAKEUP,
            calendar.timeInMillis,
            AlarmManager.INTERVAL_DAY,
            pendingIntent
        )
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.kanji_app_widget)

        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val currentView = prefs.getInt("current_view", 0)

        // 0 = Kanji, 1 = Streak
        val imagePath = if (currentView == 0) {
            pickKanjiImagePath(widgetData)
        } else {
            widgetData?.getString("streak_image_path", null)
        }

        if (imagePath != null) {
            val file = File(imagePath)
            if (file.exists()) {
                val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                views.setImageViewBitmap(R.id.widget_image, bitmap)
                views.setViewVisibility(R.id.widget_image, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_image, View.GONE)
            }
        } else {
            views.setViewVisibility(R.id.widget_image, View.GONE)
        }

        // Setup toggle intent
        val toggleIntent = Intent(context, KanjiAppWidgetProvider::class.java).apply {
            action = "TOGGLE_VIEW"
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            toggleIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun pickKanjiImagePath(widgetData: SharedPreferences?): String? {
        if (widgetData == null) return null

        // Current day image (saved on every app open)
        val current = widgetData.getString("kanji_image", null)
        if (current != null && File(current).exists()) return current

        val startDateStr = widgetData.getString("kanji_start_date", null)
        val startDate = try {
            SimpleDateFormat("yyyy-MM-dd", Locale.US).parse(startDateStr ?: return null)
        } catch (_: Exception) {
            null
        } ?: return null

        val today = Calendar.getInstance()
        val startCal = Calendar.getInstance().apply { time = startDate }

        // Day index since start
        val diffMillis = today.timeInMillis - startCal.timeInMillis
        val dayIndex = (diffMillis / (24 * 60 * 60 * 1000L)).toInt()

        // Try current day slot, fall back to any available image
        val candidate = widgetData.getString("kanji_image_path_${dayIndex % 7}", null)
        if (candidate != null && File(candidate).exists()) return candidate

        for (i in 0 until 7) {
            val path = widgetData.getString("kanji_image_path_$i", null) ?: continue
            if (File(path).exists()) return path
        }
        return null
    }
}
