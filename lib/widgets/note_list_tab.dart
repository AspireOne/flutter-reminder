import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../overlays/recording_overlay.dart';
import '../overlays/text_overlay.dart';
import 'note.dart';
import 'note_list.dart';

enum NoteState { oncoming, completed, all }
enum NoteType { voiceNote, textNote }

class NoteListTab extends StatefulWidget {
  final NoteState notesToShow;

  const NoteListTab({Key? key, required this.notesToShow}) : super(key: key);

  @override
  State<NoteListTab> createState() => _NoteListTabState();
}

class _NoteListTabState extends State<NoteListTab> with AutomaticKeepAliveClientMixin<NoteListTab> {
  static final List<Note> _notes = <Note>[];
  static bool _notesInitialized = false;
  double _voiceButtonOpacity = 1;
  double _textButtonOpacity = 1;

  _NoteListTabState() {
    // TODO: Initialize notes from storage.
    if (!_notesInitialized) _notesInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final notesToShow = _notes.where((note) {
      switch (widget.notesToShow) {
        case NoteState.completed:
          return note.dueTime.isAfter(DateTime.now());
        case NoteState.oncoming:
          return note.dueTime.isBefore(DateTime.now());
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      floatingActionButton: _AddNoteButtons(
        textButton: _AddNoteButton(
          type: NoteType.textNote,
          onPress: () {
            setState(() {
              _textButtonOpacity = 0;
              _voiceButtonOpacity = 0;
              _openOverlay(_getTextOverlay());
            });
          },
          opacity: _textButtonOpacity,
        ),
        voiceButton: _AddNoteButton(
          type: NoteType.voiceNote,
          opacity: _voiceButtonOpacity,
          onPress: () async {
            if (!(await Record().hasPermission())) return;
            setState(() {
              _textButtonOpacity = 0;
              _voiceButtonOpacity = 0;
              _openOverlay(_getRecordingOverlay());
            });
          },
        ),
      ),
      body: NoteList(
        notes: notesToShow,
        noNotesMessage: widget.notesToShow == NoteState.oncoming
            ? "No oncoming notes"
            : "No completed notes",
      )
    );
  }

  void _openOverlay(Widget overlay) async {
    await Navigator.push(context, PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => overlay
    ));
    _revertButtonsOpacity();
  }

  void _addNote({String? audioPath, String? textContent, String? id, required DateTime dueTime}) {
    id ??= const Uuid().v4();

    final note = Note(
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
    );

    _notes.add(note);
  }

  Widget _getRecordingOverlay() {
    final String id = const Uuid().v4();
    return RecordingOverlay(
      onSuccessfullyFinished: (due, path) {
        setState(() {
          _addNote(dueTime: due, id: id, audioPath: path);
          _revertButtonsOpacity();
        });
      },
      recordingId: id,
      /*onStartedPickingTime: () => setState(() => _voiceButtonOpacity = 0),*/
      /*onDismissed: () => setState(_revertButtonsOpacity),*/
    );
  }

  Widget _getTextOverlay() {
    return TextOverlay(
      onSuccessfullyFinished: (due, text) {
        setState(() {
          _addNote(dueTime: due, textContent: text);
          _revertButtonsOpacity();
        });
      },
        /*onDismissed: () => setState(_revertButtonsOpacity),*/
    );
  }

  void _revertButtonsOpacity() {
    _voiceButtonOpacity = 1;
    _textButtonOpacity = 1;
  }

  @override
  bool get wantKeepAlive => true;
}

class _AddNoteButtons extends StatefulWidget {
  final Widget textButton;
  final Widget voiceButton;

  const _AddNoteButtons({Key? key, required this.textButton, required this.voiceButton}) : super(key: key);

  @override
  State<_AddNoteButtons> createState() => _AddNoteButtonsState();
}

class _AddNoteButtonsState extends State<_AddNoteButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 25),
          widget.voiceButton,
          const SizedBox(width: 25),
          widget.textButton
        ]
    );
  }
}

class _AddNoteButton extends StatelessWidget {
  final NoteType type;
  final Function? onTouchDown;
  final Function? onTouchUp;
  final Function? onPress;
  final double opacity;

  const _AddNoteButton({required this.type, this.opacity = 1,
    this.onTouchDown, this.onTouchUp, this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTouchDown?.call(),
      onTapUp: (_) => onTouchUp?.call(),
      onTapCancel: () => onTouchUp?.call(),
      child: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton(
            onPressed: () => onPress?.call(),
            heroTag: type.toString(),
            child: Icon(type == NoteType.voiceNote
                ? Icons.record_voice_over
                : Icons.short_text_outlined),
          )
      )
    );
  }
}
