import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reminder/widgets/voice_note_content.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum UnitType { minutes, hours }

class Note extends StatefulWidget {
  final String? recordingPath;
  final String? textContent;
  final Function? onDue;

  final DateTime creationTime;
  final DateTime dueTime;
  final String? id;

  Note({super.key, required this.dueTime, required this.id, this.textContent, this.recordingPath, this.onDue}) : creationTime = DateTime.now() {
    if(textContent == null && recordingPath == null)
      throw ArgumentError("One of the parameters must be provided.");
    if (textContent != null && recordingPath != null)
      throw ArgumentError("Only one of the parameters must be provided.");
  }

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  DateTime? dueTime;
  bool isDone = false;

  @override
  void initState() {
    super.initState();
    dueTime = widget.dueTime;

    // If the note is due, then we don't need to update it.
    if (DateTime.now().isAfter(dueTime!)) {
      isDone = true;
      return;
    }

    // Update the note every minute.
    Timer.periodic(const Duration(minutes: 1), (Timer t) {
      if (isDone) {
        t.cancel();
        return;
      }
      setState(() => {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    isDone = true;
  }

  @override
  Widget build(BuildContext context) {
    if (DateTime.now().isAfter(dueTime!)) isDone = true;
    if (isDone) {
      dueTime = DateTime.now();
      widget.onDue?.call();
    }

    final dueTimeInWords = getDueTimeInWords(dueTime!);
    final creationTimeFormatted = "zádáno: ${DateFormat("d.M. H:mm").format(widget.creationTime)}";

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Container(
        decoration: getCardDecoration(),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CreationTimeText(creationTimeFormatted),
                const SizedBox(height: 10),
                widget.recordingPath != null ? VoiceNoteContent(audioPath: widget.recordingPath!) : Text(
                  widget.textContent.toString(),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                BottomPanel(
                    dueTimeInWords,
                    // If the note is already due, then the button should be disabled.
                    onMarkDonePressed: isDone ? null : () => setState(() => isDone = true)
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

  String getDueTimeInWords(DateTime dueTime) {
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
    final minutes = hours > 0 ? difference.inMinutes % 60 : difference.inMinutes;

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

class BottomPanel extends StatelessWidget {
  final String dueText;
  final VoidCallback? onMarkDonePressed;
  const BottomPanel(this.dueText, {Key? key, this.onMarkDonePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          dueText,
          style: const TextStyle(
              color: Colors.grey
          ),
          textAlign: TextAlign.left,
        ),
        TextButton(
          onPressed: onMarkDonePressed,
          child: const Text('OZNAČIT ZA DOKONČENÉ'),
        ),
      ],
    );
  }
}
