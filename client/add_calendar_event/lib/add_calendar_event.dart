import 'dart:async';

import 'package:flutter/services.dart';

class AddCalendarEvent {
  static const MethodChannel _channel =
      const MethodChannel('add_calendar_event');

  /// Add an Event (object) to user's default calendar.
  static Future<bool> addEventToCal(Event event) {
    return _channel
        .invokeMethod<bool?>('addToCal', event.toMap())
        .then((value) => value ?? false);
  }

  static Future<int> addEventListToCal(List<Event> list) {
    return _channel
        .invokeMethod<int?>(
            'addEventListToCal', list.map((e) => e.toMap()).toList())
        .then((value) => value ?? 0);
  }

  static Future<int> deleteCalEventByDesc(String desc) {
    return _channel.invokeMethod<int?>('deleteCalEventByDesc',
        <String, dynamic>{'desc': desc}).then((value) => value ?? 0);
  }
}

/// Class that holds each event's info.
class Event {
  String title, description, location;
  DateTime startDate, endDate;

  //In iOS, you can set alert notification with duration. Ex. Duration(minutes:30) -> After30 min.
  Duration? alarmInterval;

  Event({
    required this.title,
    this.description = '',
    this.location = '',
    required this.startDate,
    required this.endDate,
    this.alarmInterval,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "desc": description,
      "location": location,
      "startDate": startDate.millisecondsSinceEpoch,
      "endDate": endDate.millisecondsSinceEpoch,
      "alarmInterval": alarmInterval?.inSeconds.toInt()
    };
  }
}
