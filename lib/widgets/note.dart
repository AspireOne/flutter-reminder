import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum UnitType { minutes, hours }

class Note extends StatefulWidget {
  final DateTime dueTime;
  final DateTime creationTime;
  final String? textContent;
  final Object? voiceContent;

  Note(this.dueTime, {super.key, this.textContent, this.voiceContent}) : creationTime = DateTime.now() {
    if(textContent == null && voiceContent == null)
      throw ArgumentError("One of the parameters must be provided.");
    if (textContent != null && voiceContent != null)
      throw ArgumentError("Only one of the parameters must be provided.");
  }

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  DateTime? timeMarkedDone;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(minutes: 1), (Timer t) => setState((){}));
  }

  String getUnitFormatted(int value, UnitType type) {
    bool inMinutes = type == UnitType.minutes;

    final unitFormatFive = inMinutes ? "minut" : "hodin";
    final unitFormatTwo = inMinutes ? "minuty" : "hodiny";
    final unitFormatOne = inMinutes ? "minutu" : "hodinu";
    return value >= 5 ? unitFormatFive : value >= 2 ? unitFormatTwo : unitFormatOne;
  }

  String getDiffInWords(Duration difference) {
    final hours = difference.inHours;
    final minutes = hours > 0 ? difference.inMinutes % 60 : difference.inMinutes;

    final String minutesFormatted = minutes == 0 ? "" : "$minutes ${getUnitFormatted(minutes, UnitType.minutes)}";
    String hoursFormatted = hours == 0 ? "" : "$hours ${getUnitFormatted(hours, UnitType.hours)}";

    if (minutesFormatted != "" && hoursFormatted != "")
      hoursFormatted += " a ";

    return "$hoursFormatted$minutesFormatted";
  }

  String getDueTimeInWords(DateTime dueTime, {Duration? difference}) {
    final now = DateTime.now();
    difference ??= dueTime.difference(now);
    final isTomorrow = now.day < dueTime.day;
    final differenceInWords = getDiffInWords(difference);

    if (difference.isNegative) {
      return "Proběhlo ${DateFormat("d.M. H:mm").format(dueTime)}";
    } else if (difference.inMinutes == 0) {
      return "Probíhá právě teď";
    } else {
      return "Proběhne za $differenceInWords (${isTomorrow ? "zítra " : ""}v ${DateFormat("H:mm").format(dueTime)})";
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueTime = timeMarkedDone ?? widget.dueTime;
    final difference = dueTime.difference(DateTime.now());
    final dueTimeInWords = getDueTimeInWords(dueTime, difference: difference);

    final creationTimeFormatted = DateFormat("d.M. H:mm").format(widget.creationTime);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5.0,
              //spreadRadius: 10.0,

            ),
          ],
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "zadáno $creationTimeFormatted",
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      color: Colors.grey
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.textContent.toString(),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                BottomRow(
                    dueTimeInWords,
                    onMarkDonePressed: difference.isNegative || difference.inMinutes == 0 ? null : () {setState(() => timeMarkedDone = DateTime.now());}
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomRow extends StatelessWidget {
  final String dueTimeInWords;
  final VoidCallback? onMarkDonePressed;
  const BottomRow(this.dueTimeInWords, {Key? key, this.onMarkDonePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          dueTimeInWords,
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
