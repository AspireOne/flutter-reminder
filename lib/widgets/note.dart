import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_reminder/alarms.dart';
import 'package:flutter_reminder/extensions.dart';
import 'package:flutter_reminder/notifications.dart';
import 'package:flutter_reminder/widgets/voice_note_content.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum UnitType { minutes, hours }

class Note extends StatefulWidget {
  static final DateTime dueTimeNever = DateTime.utc(275760,09,13);
  static const String keyPrefix = "_note";
  late final DateTime creationTime;
  late final int numericId;
  final String? recordingPath;
  final String? textContent;
  final Function? onDue;
  DateTime dueTime;
  final String id;

  Note({super.key, required this.dueTime, required this.id, int? notificationsId, this.textContent, this.recordingPath, this.onDue, DateTime? creationTime}) {
    if(textContent == null && recordingPath == null)
      throw ArgumentError("One of the parameters must be provided.");
    if (textContent != null && recordingPath != null)
      throw ArgumentError("Only one of the parameters must be provided.");

    this.creationTime = creationTime ?? DateTime.now();
    this.numericId = notificationsId ?? _generateNumericId();
  }

  bool isDue() => DateTime.now().isAfter(dueTime);

  static int _generateNumericId() {
    final random = Random();
    String num = (random.nextInt(9) + 1).toString();

    for (int i = 0; i < 4; i++) {
      num += random.nextInt(10).toString();
    }
    return int.parse(num);
  }

  // Retrieve a note from shared preferences using its id.
  static Future<Note?> fromSharedPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final noteJson = prefs.getString(key);
    if (noteJson == null) throw ArgumentError("No note with id $key found in shared preferences.");
    return _fromJson(noteJson);
  }

  // Save this object to shared preferences in a json format.
  Future<void> saveToSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("$keyPrefix$id", _toJson());
  }

  // If this object is in shared prefs, update it.
  Future<void> updateInSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("$keyPrefix$id")) saveToSharedPrefs();
  }

  // Create a note from a json string.
  static Note? _fromJson(String jsonStr) {
    final Map<String, dynamic> json = jsonDecode(jsonStr);

    try {
      return Note(
        id: json['id'],
        dueTime: DateTime.parse(json['dueTime']),
        creationTime: DateTime.parse(json['creationTime']),
        recordingPath: json['recordingPath'],
        textContent: json['textContent'],
        notificationsId: json['notificationsId'],
      );
    } catch (e) {
      debugPrint("Error while parsing json note: $e");
    }
    return null;
  }

  void scheduleNotifications(int minutesBefore) {
    _schedulePreRemindNotification(minutesBefore);
    _scheduleRemindNotification();
  }

  void cancelNotifications() {
    Notifications.cancelNotification(numericId);
  }

  void _schedulePreRemindNotification(int minutesBefore) {
    if (DateTime.now().isAfter(dueTime)) return;

    DateTime scheduledTime = dueTime.subtract(Duration(minutes: minutesBefore));
    if (scheduledTime.difference(DateTime.now()).inMinutes <= minutesBefore) {
      scheduledTime = DateTime.now().add(const Duration(seconds: 2));
      minutesBefore = dueTime.difference(DateTime.now()).inMinutesRoundedUp();
    }

    final title = "${recordingPath != null ? "Voice n" : "N"}ote will take place in $minutesBefore minutes." ??
        "${recordingPath != null ? "Hlasová p" : "P"}řipomínka proběhne za $minutesBefore minut.";
    final body = textContent ?? "Click on this notification to open the voice note." ?? "Kliknutím na tuto notifikaci se k připomínce dostanete.";

    Notifications.scheduleNotification(title, body, numericId, scheduledTime);
  }

  void _scheduleRemindNotification() {
    if (DateTime.now().isAfter(dueTime)) return;

    final title = "Reminder!" ?? "Připomínka!";
    final body = textContent ?? "Click on this notification to open the voice note." ?? "Kliknutím na tuto notifikaci se k připomínce dostanete.";

    Notifications.scheduleNotification(title, body, 0, dueTime);
  }

  // Serialize this object into a JSON and return a String.
  String _toJson() {
    return jsonEncode({
      "id": id,
      "dueTime": dueTime.toIso8601String(),
      "creationTime": creationTime!.toIso8601String(),
      "textContent": textContent,
      "recordingPath": recordingPath,
    });
  }

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  //DateTime? dueTime;

  @override
  void initState() {
    super.initState();
    if (widget.isDue()) return;

    runStateUpdateTimer();

    int delay = (widget.dueTime.difference(DateTime.now()).inSeconds % 60) + 1;
    Future.delayed(Duration(seconds: delay), () => runStateUpdateTimer());
  }

  // Update the note every minute.
  void runStateUpdateTimer() {
    Timer.periodic(const Duration(minutes: 1), (Timer t) {
      if (mounted) setState(() => {});
      // If the note is due, remaining time is not shown, so theres nothing to update.
      if (widget.isDue()) {
        t.cancel();
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dueTimeInWords = getRemainingTimeInWords(widget.dueTime);
    final creationTimeFormatted = "Created: ${DateFormat("d.M. H:mm").format(widget.creationTime!)}" ??
        "zádáno: ${DateFormat("d.M. H:mm").format(widget.creationTime!)}";

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 1.0),
      child: Container(
        decoration: getCardDecoration(),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DueTimeText(dueTimeInWords),
                const SizedBox(height: 10),
                widget.recordingPath != null ? VoiceNoteContent(audioPath: widget.recordingPath!) : Text(
                  widget.textContent.toString(),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                BottomPanel(
                    creationTimeFormatted,
                    // If the note is already due, then the button should be disabled.
                    onMarkDonePressed: widget.isDue() ? null : () {
                      setState(() => widget.dueTime = DateTime.now());
                      widget.onDue?.call();
                      widget.updateInSharedPrefs();
                    }
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration getCardDecoration() {
    return const BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5.0,
        ),
      ],
    );
  }

  String getRemainingTimeInWords(DateTime dueTime) {
    if (Note.dueTimeNever.isAtSameMomentAs(dueTime))
      return "Not time limited" ?? "Časově neomezená";
    final now = DateTime.now();

    if (now.isAfter(dueTime) || now.isAtSameMomentAs(dueTime)) {
      return "Took place ${DateFormat("d.M. H:mm").format(dueTime)}" ??
        "Proběhlo ${DateFormat("d.M. H:mm").format(dueTime)}";
    } else {
      final isTomorrow = now.day < dueTime.day;
      final differenceInWords = getDiffInWords(dueTime.difference(now));
      return "Will take place in $differenceInWords (${isTomorrow ? "tomorrow " : ""}in ${DateFormat("H:mm").format(dueTime)})" ??
        "Proběhne za $differenceInWords (${isTomorrow ? "zítra " : ""}v ${DateFormat("H:mm").format(dueTime)})";
    }
  }

  String getDiffInWords(Duration difference) {
    final hours = difference.inHours;
    final minutes = hours > 0 ? difference.inMinutes % 60 : difference.inMinutesRoundedUp();

    final String minutesFormatted = minutes == 0 ? "" : "$minutes ${getUnitFormatted(minutes, UnitType.minutes)}";
    String hoursFormatted = hours == 0 ? "" : "$hours ${getUnitFormatted(hours, UnitType.hours)}";

    if (minutesFormatted != "" && hoursFormatted != "") hoursFormatted += " and ";

    return "$hoursFormatted$minutesFormatted";
  }

  String getUnitFormatted(int value, UnitType type) {
    bool inMinutes = type == UnitType.minutes;

    final unitFormatFive = inMinutes ? "minutes" ?? "minut" : "hours" ?? "hodin";
    final unitFormatTwo = inMinutes ? "minutes" ?? "minuty" : "hours" ?? "hodiny";
    final unitFormatOne = inMinutes ? "minute" ?? "minutu" : "hour" ?? "hodinu";
    return value >= 5 ? unitFormatFive : value >= 2 ? unitFormatTwo : unitFormatOne;
  }
}

class CreationTimeText extends StatelessWidget {
  final String creationTimeText;
  const CreationTimeText(this.creationTimeText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      creationTimeText,
      textAlign: TextAlign.left,
      style: const TextStyle(
          color: Colors.grey
      ),
    );
  }
}

class DueTimeText extends StatelessWidget {
  final String dueTimeText;
  const DueTimeText(this.dueTimeText, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text(
        dueTimeText,
        overflow: TextOverflow.fade,
        style: const TextStyle(
            color: Colors.grey
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}

class BottomPanel extends StatelessWidget {
  final String creationTimeText;
  final VoidCallback? onMarkDonePressed;
  const BottomPanel(this.creationTimeText, {Key? key, this.onMarkDonePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        CreationTimeText(creationTimeText),
        TextButton(
          onPressed: onMarkDonePressed,
          child: const Text("MARK DONE" ?? 'OZNAČIT ZA DOKONČENÉ'),
        ),
      ],
    );
  }
}
