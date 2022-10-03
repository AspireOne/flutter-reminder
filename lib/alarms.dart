import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

class Alarm {
  static Future<bool> setOneShot(DateTime time, Function staticOrTopLevelCallback, int id) async {
    if (time.isBefore(DateTime.now())) time = DateTime.now().add(const Duration(seconds: 1));

    return AndroidAlarmManager.oneShotAt(time, id, staticOrTopLevelCallback,
        exact: true, rescheduleOnReboot: true, wakeup: true, alarmClock: true);
  }

  static Future<bool> cancel(int id) async {
    return AndroidAlarmManager.cancel(id);
  }
}