package io.github.mamoonalmazloom.salatontime

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.SystemClock
import android.text.format.DateFormat
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.util.Date

/**
 * Home-screen widget: next prayer + live leave-home countdown.
 *
 * The Flutter side (AlertRescheduler) writes the upcoming schedule as JSON
 * into home_widget's SharedPreferences whenever alerts are rescheduled
 * (app open + the 12h background refresh). This provider picks the next
 * entry at render time.
 *
 * A single widget definition adapts across four hand-designed layouts —
 * pill (2x1), square (2x2), wide (4x1), large-with-forecast (4x2) — using
 * the Android 12+ size-mapped RemoteViews API, so resizing on the home
 * screen swaps the look live (matching how OEM weather widgets behave).
 * Pre-S devices fall back to picking the closest layout from the widget's
 * reported min width/height and re-render on resize via
 * onAppWidgetOptionsChanged, since they never see the size map.
 */
class SalatWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (widgetId in appWidgetIds) {
            appWidgetManager.updateAppWidget(widgetId, viewsFor(context, appWidgetManager, widgetId))
        }
        armRolloverAlarm(context)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        // Pre-S devices never get the size-mapped RemoteViews, so resizing
        // must be handled by hand here. On S+ the system re-selects the
        // right entry from the map on its own.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            appWidgetManager.updateAppWidget(appWidgetId, viewsFor(context, appWidgetManager, appWidgetId))
        }
    }

    private fun viewsFor(context: Context, appWidgetManager: AppWidgetManager, widgetId: Int): RemoteViews {
        val data = loadSchedule(context)
        val now = System.currentTimeMillis()
        val next = data?.entries?.firstOrNull { it.leaveMillis > now }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            responsiveViews(context, next, data, now)
        } else {
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val widthDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 250)
            val heightDp = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 110)
            buildLayout(context, layoutFor(widthDp, heightDp), next, data, now)
        }
    }

    private fun layoutFor(widthDp: Int, heightDp: Int): Int {
        val wide = widthDp >= 180
        val tall = heightDp >= 100
        return when {
            wide && tall -> R.layout.widget_salat_large
            wide -> R.layout.widget_salat_wide
            tall -> R.layout.widget_salat_square
            else -> R.layout.widget_salat_pill
        }
    }

    private fun responsiveViews(
        context: Context,
        next: Entry?,
        data: Schedule?,
        now: Long,
    ): RemoteViews {
        val mapping = mapOf(
            SizeF(110f, 40f) to buildLayout(context, R.layout.widget_salat_pill, next, data, now),
            SizeF(110f, 100f) to buildLayout(context, R.layout.widget_salat_square, next, data, now),
            SizeF(180f, 40f) to buildLayout(context, R.layout.widget_salat_wide, next, data, now),
            SizeF(180f, 100f) to buildLayout(context, R.layout.widget_salat_large, next, data, now),
        )
        return RemoteViews(mapping)
    }

    private fun buildLayout(
        context: Context,
        layoutRes: Int,
        next: Entry?,
        data: Schedule?,
        now: Long,
    ): RemoteViews {
        val views = RemoteViews(context.packageName, layoutRes)

        if (next == null) {
            views.setTextViewText(R.id.widget_prayer, appName(context))
            views.setTextViewText(R.id.widget_label, "")
            views.setTextViewText(R.id.widget_leave_at, "…")
            views.setViewVisibility(R.id.widget_countdown, View.GONE)
        } else {
            views.setTextViewText(R.id.widget_prayer, next.prayer)
            views.setTextViewText(R.id.widget_label, data?.leaveLabel ?: "")
            val clock = DateFormat.getTimeFormat(context).format(Date(next.leaveMillis))
            views.setTextViewText(R.id.widget_leave_at, clock)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val base = SystemClock.elapsedRealtime() + (next.leaveMillis - now)
                views.setViewVisibility(R.id.widget_countdown, View.VISIBLE)
                views.setChronometerCountDown(R.id.widget_countdown, true)
                views.setChronometer(R.id.widget_countdown, base, null, true)
            } else {
                views.setViewVisibility(R.id.widget_countdown, View.GONE)
            }
        }

        populateForecastRows(views, context, data, now)

        val launch = Intent(context, MainActivity::class.java)
        val pending = PendingIntent.getActivity(
            context, 0, launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        views.setOnClickPendingIntent(R.id.widget_root, pending)
        return views
    }

    /** Only present in the 4x2 layout; a no-op (missing-id) on the others. */
    private fun populateForecastRows(views: RemoteViews, context: Context, data: Schedule?, now: Long) {
        val upcoming = data?.entries?.filter { it.leaveMillis > now } ?: emptyList()
        val rows = listOf(
            Triple(R.id.widget_row1, R.id.widget_row1_name, R.id.widget_row1_time),
            Triple(R.id.widget_row2, R.id.widget_row2_name, R.id.widget_row2_time),
            Triple(R.id.widget_row3, R.id.widget_row3_name, R.id.widget_row3_time),
            Triple(R.id.widget_row4, R.id.widget_row4_name, R.id.widget_row4_time),
        )
        for ((index, ids) in rows.withIndex()) {
            val (rowId, nameId, timeId) = ids
            val entry = upcoming.getOrNull(index)
            if (entry == null) {
                views.setViewVisibility(rowId, View.GONE)
            } else {
                views.setViewVisibility(rowId, View.VISIBLE)
                views.setTextViewText(nameId, entry.prayer)
                views.setTextViewText(timeId, DateFormat.getTimeFormat(context).format(Date(entry.leaveMillis)))
            }
        }
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
