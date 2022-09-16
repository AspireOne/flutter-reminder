// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ActionButtonType { voiceNote, textNote }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ADHD Reminder',
        home: Scaffold(
          appBar: AppBar(
            title: const Text("ADHD Reminder"),
            actions: [
              IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => {},
                  tooltip: "Menu"
              )
            ],
          ),

          body: DefaultTabController(
              length: 2,
              child: Scaffold(
                body: const TabBarView(
                  children: [
                    NoteList(),
                    Icon(Icons.directions_transit),
                  ],
                ),
                appBar: AppBar(
                  bottom: const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.record_voice_over)),
                      Tab(icon: Icon(Icons.history)),
                    ],
                  ),
                ),
              )
          ),
        )
    );
  }
}

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final List<Note> _notes = <Note>[];

  @override
  Widget build(BuildContext context) {
    _notes.add(Note(DateTime.now().add(const Duration(minutes: 26)), textContent: "This is some note that you can note.")); // TODO: Remove this debug.
    Widget body;
    if (_notes.isEmpty) {
      body = const Center(
          child: Text(
              "You have no ongoing reminders!",
              textAlign: TextAlign.center
          )
      );
    } else {
      body = ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, i) {
          return _notes[i];
        },
      );
    }
    return Scaffold(
      body: body,
      floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const ActionButton(ActionButtonType.voiceNote),
            ActionButton(ActionButtonType.textNote, onTouchDown: () {
              setState(() => _notes.add(Note(DateTime.now(), textContent: "some text")));
            })
          ]
      )
    );
  }
}

class Note extends StatefulWidget {
  final DateTime dueTime;
  final DateTime creationTime;
  final String? textContent;
  final Object? voiceContent;

  Note(this.dueTime, {super.key, this.textContent, this.voiceContent}) : creationTime = DateTime.now() {
    if(textContent == null && voiceContent == null)
      throw ArgumentError("One of the parameters must be provided.");
    if (textContent != null && voiceContent != null)
      throw ArgumentError("Only one of the two parameters must be provided.");
  }

  @override
  State<Note> createState() => _NoteState();
}

enum UnitType { minutes, hours }
class _NoteState extends State<Note> {
  DateTime? timeMarkedDone = null;

  String getUnitFormatted(int value, UnitType type) {
    bool inMinutes = type == UnitType.minutes;

    final unitFormatFive = inMinutes ? "minut" : "hodin";
    final unitFormatTwo = inMinutes ? "minuty" : "hodiny";
    final unitFormatOne = inMinutes ? "minutu" : "hodinu";
    return value >= 5 ? unitFormatFive : value >= 2 ? unitFormatTwo : unitFormatOne;
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(minutes: 1), (Timer t) => setState((){}));
  }

  String formatDifference(Duration difference) {
    final minutes = difference.inMinutes;
    final hours = difference.inHours;

    final String minutesFormatted = minutes == 0 ? "" : "$minutes ${getUnitFormatted(minutes, UnitType.minutes)}";
    String hoursFormatted = hours == 0 ? "" : "$hours ${getUnitFormatted(hours, UnitType.hours)}";

    if (minutesFormatted != "" && hoursFormatted != "")
      hoursFormatted += " a ";

    return "$hoursFormatted $minutesFormatted";
  }

  @override
  Widget build(BuildContext context) {
    final dueTime = timeMarkedDone ?? widget.dueTime;
    final difference = dueTime.difference(DateTime.now());
    final isTomorrow = DateTime.now().day < dueTime.day;

    final differenceInWords = formatDifference(difference);
    String dueTimeInWords;
    if (difference.isNegative) {
      dueTimeInWords = "Proběhlo ${DateFormat("d.M. H:mm").format(dueTime)}";
    } else if (difference.inMinutes == 0) {
      dueTimeInWords = "Probíhá právě teď";
    } else {
      dueTimeInWords = "Proběhne za$differenceInWords (${isTomorrow ? "zítra " : ""}v ${DateFormat("H:mm").format(dueTime)})";
    }

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
              children: [
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
                Row(
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
                      child: const Text('OZNAČIT ZA DOKONČENÉ'),
                      onPressed: difference.isNegative || difference.inMinutes == 0 ? null : () {setState(() => timeMarkedDone = DateTime.now());},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final ActionButtonType type;
  final Function? onTouchDown;
  final Function? onTouchUp;
  final Function? onPress;

  const ActionButton(this.type, {super.key, this.onTouchDown, this.onTouchUp, this.onPress });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {onTouchDown?.call();},
      onTapUp: (_) {onTouchUp?.call();},
      child: FloatingActionButton(
        onPressed: () {onPress?.call();},
        heroTag: type.toString(),
        child: Icon(type == ActionButtonType.voiceNote ? Icons.mic : Icons.short_text_outlined),
      ),
    );
  }
}