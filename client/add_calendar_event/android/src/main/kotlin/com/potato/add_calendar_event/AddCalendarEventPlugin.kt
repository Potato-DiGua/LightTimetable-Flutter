package com.potato.add_calendar_event

import android.Manifest
import android.app.Activity
import android.content.*
import android.net.Uri
import android.provider.CalendarContract
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.PermissionChecker.PERMISSION_GRANTED
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.lang.Exception
import java.util.*


/** AddCalendarEventPlugin */
class AddCalendarEventPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var coroutineScope: CoroutineScope? = null
    private lateinit var applicationContext: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "add_calendar_event")
        channel.setMethodCallHandler(this)

        applicationContext = flutterPluginBinding.applicationContext
        coroutineScope = CoroutineScope(Dispatchers.IO)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        coroutineScope?.cancel()
        coroutineScope = null
    }

    private var activity: Activity? = null

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {

        if (!requestPermission()) {
            result.error("没有日历权限", null, null)
            return
        }
        when (call.method) {
            "addToCal" -> {
                coroutineScope!!.launch {
                    try {

                        @Suppress("UNCHECKED_CAST")
                        val success = insert(Event.fromMap(call.arguments as Map<String, Any>))
                        withContext(Dispatchers.Main) {
                            result.success(success)
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            result.error("Exception occurred in Android code", e.message, false)
                        }
                    }

                }

            }
            "addEventListToCal" -> {
                coroutineScope!!.launch {
                    try {

                        @Suppress("UNCHECKED_CAST")
                        val count = insertEventList(
                                (call.arguments as List<*>).map {
                                    return@map Event.fromMap(it as Map<String, Any>)
                                }.toList()
                        )

                        withContext(Dispatchers.Main) {
                            result.success(count)
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            result.error("Exception occurred in Android code", e.message, false)
                        }

                    }
                }
            }
            "deleteCalEventByDesc" -> {
                coroutineScope!!.launch {
                    try {
                        val rows = deleteCalEventByDesc(call.argument<String>("desc"))
                        withContext(Dispatchers.Main) {
                            result.success(rows)
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            result.error("Exception occurred in Android code", e.message, false)
                        }
                    }
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun checkPermission(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(applicationContext, permission) == PERMISSION_GRANTED
    }

    private fun requestPermission(): Boolean {
        val callbackId = 0xf42

        val permissions = checkPermission(Manifest.permission.WRITE_CALENDAR) && checkPermission(Manifest.permission.READ_CALENDAR)
        if (!permissions) {
            ActivityCompat.requestPermissions(activity!!, arrayOf(Manifest.permission.WRITE_CALENDAR, Manifest.permission.READ_CALENDAR), callbackId)
        }
        return permissions
    }

    private val eventsUri: Uri = CalendarContract.Events.CONTENT_URI
    private val remindersUri = CalendarContract.Reminders.CONTENT_URI


    /**
     * 添加日历事件
     */
    private fun insert(event: Event): Boolean {
        try {

            val cr: ContentResolver = applicationContext.contentResolver

            val values = ContentValues().apply {
                put(CalendarContract.Events.CALENDAR_ID, 1)
                put(CalendarContract.Events.TITLE, event.title)
                put(CalendarContract.Events.DESCRIPTION, event.desc)
                put(CalendarContract.Events.EVENT_LOCATION, event.loc)
                put(CalendarContract.Events.DTSTART, event.start)
                put(CalendarContract.Events.DTEND, event.end)
                put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
            }

            val uri: Uri? = cr.insert(eventsUri, values)

            if (event.alarm != null) {
                return insertCalendarAlarm(uri, (event.alarm / 60.0f).toInt()) != null
            }
            return true
        } catch (e: Exception) {
            Log.e(this.javaClass.name, e.message, e)
        }
        return false
    }


    private fun insertEventList(events: List<Event>): Int {
        if (events.isNullOrEmpty()) return 0

        try {
            val values = events.map { event ->
                return@map ContentValues().apply {
                    put(CalendarContract.Events.CALENDAR_ID, 1)
                    put(CalendarContract.Events.TITLE, event.title)
                    put(CalendarContract.Events.DESCRIPTION, event.desc)
                    put(CalendarContract.Events.EVENT_LOCATION, event.loc)
                    put(CalendarContract.Events.DTSTART, event.start)
                    put(CalendarContract.Events.DTEND, event.end)
                    put(CalendarContract.Events.EVENT_TIMEZONE, TimeZone.getDefault().id)
                }
            }.toTypedArray()

            val cr: ContentResolver = applicationContext.contentResolver
            val count = cr.bulkInsert(eventsUri, values)
            val ids = cr.query(eventsUri, arrayOf(CalendarContract.Events._ID),
                    CalendarContract.Events.DESCRIPTION + "=?", arrayOf(events[0].desc), CalendarContract.Events._ID).use { cursor ->
                val ids: MutableList<Long> = LinkedList()
                if (cursor == null) return@use ids

                val index = cursor.getColumnIndex(CalendarContract.Events._ID)
                while (cursor.moveToNext()) {
                    ids.add(cursor.getLong(index))
                }
                return@use ids
            }
            if (ids.size == events.size) {
                var i = 0
                cr.bulkInsert(remindersUri, ids.map {
                    return@map ContentValues().apply {
                        put(CalendarContract.Reminders.EVENT_ID, it)
                        put(CalendarContract.Reminders.MINUTES, (events[i++].alarm?.div(60.0f))?.toInt()) // 提前previousMinute分钟提醒
                        put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_ALERT)
                    }
                }.toTypedArray())
            }
            return count
        } catch (e: Exception) {
            Log.e(this.javaClass.name, e.message, e)
        }
        return 0
    }


    /**
     * 添加提醒
     *
     * @param context        context
     * @param event          日程事件uri
     * @param previousMinute 提前previousMinute分钟提醒
     * @return
     */
    private fun insertCalendarAlarm(event: Uri?, previousMinute: Int): Uri? {
        if (event == null) return null
        //事件提醒的设定
        val values = ContentValues().apply {
            put(CalendarContract.Reminders.EVENT_ID, ContentUris.parseId(event))
            put(CalendarContract.Reminders.MINUTES, previousMinute) // 提前previousMinute分钟提醒
            put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_ALERT)
        }

        return applicationContext.contentResolver.insert(remindersUri, values)
    }

    private fun deleteCalEventByDesc(desc: String?): Int {
        CalendarContract.Events.CUSTOM_APP_PACKAGE
        if (desc == null) return 0
        return applicationContext.contentResolver.delete(eventsUri,
                CalendarContract.Events.DESCRIPTION + "=?", arrayOf(desc))

    }
}

data class Event(val title: String?, val desc: String?, val loc: String?, val start: Long, val end: Long, val alarm: Int?) {
    companion object {
        fun fromMap(map: Map<String, Any>): Event {
            return Event(
                    map["title"] as String?,
                    map["desc"] as String?,
                    map["location"] as String?,
                    map["startDate"] as Long,
                    map["endDate"] as Long,
                    map["alarmInterval"] as Int?,
            )
        }
    }
}

