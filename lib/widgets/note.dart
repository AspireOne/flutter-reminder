import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_reminder/alarms.dart';
import 'package:flutter_reminder/notifications.dart';
import 'package:flutter_reminder/widgets/voice_note_content.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

enum UnitType { minutes, hours }

class Note extends StatefulWidget {
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

  void schedulePreRemindNotification(int minutesBefore) {
    if (DateTime.now().isAfter(dueTime)) return;
    final remainingMinutes = dueTime.add(const Duration(seconds: 2)).difference(DateTime.now()).inMinutes;

    final title = "${recordingPath != null ? "Hlasová p" : "P"}řipomínka proběhne za $remainingMinutes minut.";
    final body = textContent ?? "Kliknutím na tuto notifikaci se dostanete k připomínce.";
    DateTime scheduledTime = dueTime.subtract(Duration(minutes: minutesBefore));
    if (scheduledTime.difference(DateTime.now()).inMinutes.abs() <= minutesBefore) {
      scheduledTime = DateTime.now().add(const Duration(seconds: 1));
    }

    Notifications.scheduleNotification(title, body, numericId, scheduledTime);
  }

  void cancelScheduledNotifications() {
    Notifications.cancelNotification(numericId);
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
    if (!isDue()) setStateUpdateTimer();
  }

  // Update the note every minute.
  void setStateUpdateTimer() {
    Timer.periodic(const Duration(minutes: 1), (Timer t) {
      if (mounted) setState(() => {});
      // If the note is due, remaining time is not shown, so theres nothing to update.
      if (isDue()) {
        t.cancel();
        return;
      }
    });
  }

  bool isDue() => DateTime.now().isAfter(widget.dueTime);

  @override
  Widget build(BuildContext context) {
    final dueTimeInWords = getRemainingTimeInWords(widget.dueTime);
    final creationTimeFormatted = "zádáno: ${DateFormat("d.M. H:mm").format(widget.creationTime!)}";

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
                    onMarkDonePressed: isDue() ? null : () {
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
    final now = DateTime.now();

    if (now.isAfter(dueTime) || now.isAtSameMomentAs(dueTime)) {
      return "Proběhlo ${DateFormat("d.M. H:mm").format(dueTime)}";
    } else {
      final isTomorrow = now.day < dueTime.day;
      final differenceInWords = getDiffInWords(dueTime.difference(now));
      return "Proběhne za $differenceInWords (${isTomorrow ? "zítra " : ""}v ${DateFormat("H:mm").format(dueTime)})";
    }
  }

  String getDiffInWords(Duration difference) {
    final hours = difference.inHours;
    final minutes = hours > 0 ? difference.inMinutes % 60 : difference.inMinutes + 1;

    final String minutesFormatted = minutes == 0 ? "" : "$minutes ${getUnitFormatted(minutes, UnitType.minutes)}";
    String hoursFormatted = hours == 0 ? "" : "$hours ${getUnitFormatted(hours, UnitType.hours)}";

    if (minutesFormatted != "" && hoursFormatted != "") hoursFormatted += " a ";

    return "$hoursFormatted$minutesFormatted";
  }

  String getUnitFormatted(int value, UnitType type) {
    bool inMinutes = type == UnitType.minutes;

    final unitFormatFive = inMinutes ? "minut" : "hodin";
    final unitFormatTwo = inMinutes ? "minuty" : "hodiny";
    final unitFormatOne = inMinutes ? "minutu" : "hodinu";
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
          child: const Text('OZNAČIT ZA DOKONČENÉ'),
        ),
      ],
    );
  }
}
