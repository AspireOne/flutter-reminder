import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:uuid/uuid.dart';

import '../overlays/recording_overlay.dart';
import '../overlays/text_overlay.dart';
import 'note.dart';
import 'note_list.dart';

enum ActionButtonType { voiceNote, textNote }

enum TabType { ongoingNotes, notesHistory }

class NoteListTab extends StatefulWidget {
  final TabType tabType;

  const NoteListTab({Key? key, required this.tabType}) : super(key: key);

  @override
  State<NoteListTab> createState() => _NoteListTabState();
}

class _NoteListTabState extends State<NoteListTab> with AutomaticKeepAliveClientMixin<NoteListTab> {
  static final List<Note> _notes = <Note>[];
  static bool _notesInitialized = false;
  bool _takingVoiceNote = false;
  bool _takingTextNote = false;

  _NoteListTabState() {
    // TODO: Initialize notes from storage.
    if (!_notesInitialized) {
      _notesInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    //final notesToShow = _notes.where((note) => widget.tabType == TabType.dueNotes ? note.).toList();

    var body = Scaffold(
        body: NoteList(
          notes: _notes,
          noNotesMessage: widget.tabType == TabType.ongoingNotes
              ? "No ongoing notes"
              : "No notes history",
        ),
/*        // TODO: Do not show buttons in history tab.
        floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _ActionButton(ActionButtonType.voiceNote, onPress: () {
            _onNoteCreated(audioPath: "", dueTime: DateTime.now().add(Duration(minutes: 10)));
            _takingVoiceNote = true;
          }),
          SizedBox(width: 25),
          _ActionButton(ActionButtonType.textNote, onPress: () {
            _takingTextNote = true;
            _onNoteCreated(textContent: "this is a text note", dueTime: DateTime.now().add(Duration(minutes: 10)));
          })
        ])*/
    );

    Widget overlay;

    if (_takingVoiceNote) {
      overlay = RecordingOverlay(onFinished: (path, due) => _onNoteCreated(dueTime: due, audioPath: path));
    }
    else if (_takingTextNote) {
      overlay = TextOverlay(onFinished: (text, due) => _onNoteCreated(dueTime: due, textContent: text));
    }
    else {
      overlay = Container();
    }
    return Stack(
      children: [
        body,
        overlay,
        Scaffold(
          // TODO: Do not show buttons in history tab.
            floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _ActionButton(ActionButtonType.voiceNote, onPress: () {
                _onNoteCreated(audioPath: "", dueTime: DateTime.now().add(Duration(minutes: 10)));
                _takingVoiceNote = true;
              }),
              SizedBox(width: 25),
              _ActionButton(ActionButtonType.textNote, onPress: () {
                _takingTextNote = true;
                _onNoteCreated(textContent: "this is a text note", dueTime: DateTime.now().add(Duration(minutes: 10)));
              })
            ])
        )
      ]
    );
  }

  void _onNoteCreated({String? audioPath, String? textContent, required DateTime dueTime}) {
    final id = const Uuid().v4();
    setState(() {
      _takingVoiceNote = false;
      _takingTextNote = false;
      _notes.add(
        Note(
          id: id,
          dueTime: dueTime,
          recordingPath: audioPath,
          textContent: textContent,
          onDue: () {
            // Defer the setState call to a next tick, otherwise an error is thrown.
            Future.delayed(Duration.zero, () async {
              setState(() => _notes.removeWhere((note) => note.id == id));
            });
          },
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}

/*class _TextActionButton extends StatelessWidget {
  final Function(Function(List<Note>)) updateNotes;
  const _TextActionButton({Key? key, required this.updateNotes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ActionButton(ActionButtonType.textNote, onPress: () {
      updateNotes((notes) {
        final noteId = const Uuid().v4();
        notes.add(
          Note(
            id: noteId,
            dueTime: DateTime.now().add(const Duration(minutes: 26, hours: 0)),
            textContent: "This is some note that you can note.",
            onDue: () {
              // Defer the setState call to a next tick, otherwise an error is thrown.
              Future.delayed(Duration.zero, () async {
                updateNotes((notes) => notes.removeWhere((note) => note.id == noteId));
              });
            },
          ),
        );
      });
    });
  }
}*/

class _ActionButton extends StatelessWidget {
  final ActionButtonType type;
  final Function? onTouchDown;
  final Function? onTouchUp;
  final Function? onPress;

  const _ActionButton(this.type,
      {super.key, this.onTouchDown, this.onTouchUp, this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTouchDown?.call(),
      onTapUp: (_) => onTouchUp?.call(),
      child: FloatingActionButton(
        onPressed: () => onPress?.call(),
        heroTag: type.toString(),
        child: Icon(type == ActionButtonType.voiceNote
            ? Icons.record_voice_over
            : Icons.short_text_outlined),
      ),
    );
  }
}
