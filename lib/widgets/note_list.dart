import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'note.dart';

enum ActionButtonType { voiceNote, textNote }

class NoteList extends StatefulWidget {
  const NoteList({Key? key}) : super(key: key);

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> with AutomaticKeepAliveClientMixin<NoteList> {
  final List<Note> _notes = <Note>[];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _notes.add(Note(DateTime.now().add(const Duration(minutes: 26, hours: 0)), textContent: "This is some note that you can note.")); // TODO: Remove this debug.
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
              const _ActionButton(ActionButtonType.voiceNote),
              _ActionButton(ActionButtonType.textNote, onTouchDown: () {
                setState(() => _notes.add(Note(DateTime.now(), textContent: "some text")));
              })
            ]
        )
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ActionButton extends StatelessWidget {
  final ActionButtonType type;
  final Function? onTouchDown;
  final Function? onTouchUp;
  final Function? onPress;

  const _ActionButton(this.type, {super.key, this.onTouchDown, this.onTouchUp, this.onPress });

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