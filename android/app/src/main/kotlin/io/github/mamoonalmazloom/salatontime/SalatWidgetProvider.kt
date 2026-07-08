package io.github.mamoonalmazloom.salatontime

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.text.format.DateFormat
import android.widget.RemoteViews
import org.json.JSONObject
import java.util.Date

/**
 * Home-screen widget: next prayer + live leave-home countdown.
 *
 * The Flutter side (AlertRescheduler) writes the upcoming schedule as JSON
 * into home_widget's SharedPreferences whenever alerts are rescheduled
 * (app open + the 12h background refresh). This provider picks the next
 * entry at render time, shows a Chronometer counting down to it (no
 * periodic updates needed while it ticks), and arms one alarm to re-render
 * when the leave moment passes.
 */
class SalatWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (widgetId in appWidgetIds) {
            appWidgetManager.updateAppWidget(widgetId, buildViews(context))
        }
        armRolloverAlarm(context)
    }

    private fun buildViews(context: Context): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_salat)
        val data = loadSchedule(context)
        val now = System.currentTimeMillis()
        val next = data?.entries?.firstOrNull { it.leaveMillis > now }

        if (next == null) {
            // No data yet (or schedule exhausted): show the app name and
            // invite a tap; the app refreshes the schedule on open.
            views.setTextViewText(R.id.widget_prayer, appName(context))
            views.setTextViewText(R.id.widget_mosque, "")
            views.setTextViewText(R.id.widget_label, "")
            views.setTextViewText(R.id.widget_leave_at, "…")
            views.setViewVisibility(R.id.widget_countdown, android.view.View.GONE)
        } else {
            views.setTextViewText(R.id.widget_prayer, next.prayer)
            views.setTextViewText(R.id.widget_mosque, next.mosque)
            views.setTextViewText(R.id.widget_label, data.leaveLabel)
            val clock = DateFormat.getTimeFormat(context).format(Date(next.leaveMillis))
            views.setTextViewText(R.id.widget_leave_at, clock)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val base = SystemClock.elapsedRealtime() + (next.leaveMillis - now)
                views.setViewVisibility(R.id.widget_countdown, android.view.View.VISIBLE)
                views.setChronometerCountDown(R.id.widget_countdown, true)
                views.setChronometer(R.id.widget_countdown, base, null, true)
            } else {
                views.setViewVisibility(R.id.widget_countdown, android.view.View.GONE)
            }
        }

        val launch = Intent(context, MainActivity::class.java)
        val pending = PendingIntent.getActivity(
            context, 0, launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        views.setOnClickPendingIntent(R.id.widget_root, pending)
        return views
    }

    /** Re-render right after the current leave moment so the widget rolls
     *  over to the next prayer without waiting for the periodic update. */
    private fun armRolloverAlarm(context: Context) {
        val data = loadSchedule(context) ?: return
        val now = System.currentTimeMillis()
        val next = data.entries.firstOrNull { it.leaveMillis > now } ?: return

        val intent = Intent(context, SalatWidgetProvider::class.java)
            .setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            android.content.ComponentName(context, SalatWidgetProvider::class.java))
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        val pending = PendingIntent.getBroadcast(
            context, 1001, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

        val alarms = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val at = next.leaveMillis + 1000
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
            alarms.canScheduleExactAlarms()
        ) {
            alarms.setExactAndAllowWhileIdle(AlarmManager.RTC, at, pending)
        } else {
            alarms.setAndAllowWhileIdle(AlarmManager.RTC, at, pending)
        }
    }

    private fun appName(context: Context): String =
        context.applicationInfo.loadLabel(context.packageManager).toString()

    private data class Entry(
        val prayer: String,
        val mosque: String,
        val leaveMillis: Long,
    )

    private data class Schedule(val leaveLabel: String, val entries: List<Entry>)

    private fun loadSchedule(context: Context): Schedule? {
        val prefs = context.getSharedPreferences(
            "HomeWidgetPreferences", Context.MODE_PRIVATE)
        val raw = prefs.getString("schedule", null) ?: return null
        return try {
            val json = JSONObject(raw)
            val list = json.getJSONArray("entries")
            val entries = buildList {
                for (i in 0 until list.length()) {
                    val e = list.getJSONObject(i)
                    add(Entry(
                        prayer = e.getString("n"),
                        mosque = e.optString("m", ""),
                        leaveMillis = e.getLong("t"),
                    ))
                }
            }
            Schedule(json.optString("leaveLabel", ""), entries)
        } catch (_: Exception) {
            null
        }
    }
}
