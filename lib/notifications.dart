import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class Notifications {
  static const String _channelId = 'oncoming_notes';
  static const String _channelName = 'Oncoming notes';
  static const String _channelDescription = 'Notifications about oncoming notes';
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<NotificationAppLaunchDetails?> initialize() async {
    var initializationSettings = const InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    return _flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  static Future<void> scheduleNotification(String title, String body, int id, DateTime time) async {
    _configureLocalTimeZone();
    var tzTime = tz.TZDateTime.from(time, tz.local);

    const details = NotificationDetails(android: AndroidNotificationDetails(
      _channelId, _channelName,
      channelDescription: _channelDescription,
      //ongoing: true,
      importance: Importance.max,
      priority: Priority.high,
    ));

    await _flutterLocalNotificationsPlugin.zonedSchedule(
        id, title, body, tzTime, details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: id.toString());
  }

  // Cancel a notification by its id.
  static Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }
}