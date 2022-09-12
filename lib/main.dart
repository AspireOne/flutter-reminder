// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  //_notesList.add(Note(DateTime.now(), textContent: "some text"));
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


/*class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}*/

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  final List<Note> _notes = <Note>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, i) {
          if (_notes.isEmpty) {
            return const Text("no note");
          }

          return _notes[i];
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _notes.add(Note(DateTime.now(), textContent: "some text"));
          });
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.navigation),
      ),
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
    return ListTile(
      title: Text(
        widget.textContent!,
      ),
      trailing: const Icon(
        Icons.favorite,
        color: Colors.red,
        semanticLabel: 'Save',
      ),
    );
  }
}

/*class _NotesState extends State<Notes> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _biggerFont = const TextStyle(fontSize: 18);

  void _pushSaved() {
    Navigator.of(context).push(
      // Add lines from here...
      // The route / the screen
      MaterialPageRoute<void>(
        // The content of the route/screen.
        builder: (context) {
          final tiles = _saved.map(
                (pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ), // ...to here.
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemBuilder: *//*1*//* (context, i) {
        if (i.isOdd) return const Divider(); *//*2*//*

        final index = i ~/ 2; *//*3*//*
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10)); *//*4*//*
        }

        final alreadySaved = _saved.contains(_suggestions[index]);
        return ListTile(
          title: Text(
            _suggestions[index].asString,
            style: _biggerFont,
          ),
          trailing: Icon(
            alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red : null,
            semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
          ),
          onTap: () {
            setState(() {
              if (alreadySaved) {
                _saved.remove(_suggestions[index]);
              } else {
                _saved.add(_suggestions[index]);
              }
            });
          },
        );
      },
    );
  }
}*/
