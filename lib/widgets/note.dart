import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reminder/widgets/voice_note_content.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum UnitType { minutes, hours }

class Note extends StatefulWidget {
  final String? recordingPath;
  final String? textContent;
  final String? id;
  final Function? onDue;
  final DateTime creationTime;
  DateTime dueTime;

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
                    onMarkDonePressed: isDue() ? null : () => setState(() => widget.dueTime = DateTime.now())
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

class BottomPanel extends StatelessWidget {
  final String dueText;
  final VoidCallback? onMarkDonePressed;
  const BottomPanel(this.dueText, {Key? key, this.onMarkDonePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            dueText,
            overflow: TextOverflow.visible,
            style: const TextStyle(
                color: Colors.grey
            ),
            textAlign: TextAlign.left,
          ),
        ),
        TextButton(
          onPressed: onMarkDonePressed,
          child: const Text('OZNAČIT ZA DOKONČENÉ'),
        ),
      ],
    );
  }
}
