// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
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
    _notes.add(Note(DateTime.now(), textContent: "some text")); // TODO: Remove this debug.
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
  final DateTime remindTime;
  final DateTime creationTime;
  final String? textContent;
  final Object? voiceContent;

  Note(this.remindTime, {super.key, this.textContent, this.voiceContent}) : creationTime = DateTime.now() {
    if(textContent == null && voiceContent == null)
      throw ArgumentError("One of the parameters must be provided.");
    if (textContent != null && voiceContent != null)
      throw ArgumentError("Only one of the two parameters must be provided.");
  }

  @override
  State<Note> createState() => _NoteState();
}

class _NoteState extends State<Note> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "zadáno 1.9. 16:00",
              textAlign: TextAlign.left,
              style: TextStyle(
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
                const Text(
                  "Proběhne za 30 minut",
                  style: TextStyle(
                    color: Colors.grey
                  ),
                  textAlign: TextAlign.left,
                ),
                TextButton(
                  child: const Text('OZNAČIT ZA DOKONČENÉ'),
                  onPressed: () {/* ... */},
                ),
              ],
            ),
          ],
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