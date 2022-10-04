import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reminder/alarms.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';

import '../notifications.dart';
import '../overlays/recording_overlay.dart';
import '../overlays/text_overlay.dart';
import 'note.dart';
import 'note_list.dart';

enum NoteState { oncoming, completed, all }
enum NoteType { voiceNote, textNote }


StreamController _onNotesUpdatedController = StreamController.broadcast();
Stream get onNotesUpdated => _onNotesUpdatedController.stream;

class NoteListTab extends StatefulWidget {
  final NoteState notesToShow;
  final bool showButtons;

  const NoteListTab({Key? key, required this.notesToShow, required this.showButtons}) : super(key: key);

  @override
  State<NoteListTab> createState() => _NoteListTabState();
}

class _NoteListTabState extends State<NoteListTab> with AutomaticKeepAliveClientMixin<NoteListTab> {
  static final List<Note> _notes = <Note>[];
  static bool _notesInitialized = false;
  double _voiceButtonOpacity = 1;
  double _textButtonOpacity = 1;

  _NoteListTabState() {
    if (_notesInitialized) return;
    _notesInitialized = true;

    SharedPreferences.getInstance().then((data) {
      data.getKeys().forEach((key) {
        if (key.startsWith(Note.keyPrefix)) {
          Note.fromSharedPrefs(key).then((note) {
            if (note != null) _notes.add(note);
          });
        }
      });
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    onNotesUpdated.listen((noteId) {
      final Note note = _notes.firstWhere((note) => note.id == noteId);
      note.cancelScheduledNotifications();
      Alarm.cancel(note.numericId);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var notesToShow = _notes.where((note) {
      switch (widget.notesToShow) {
        case NoteState.oncoming:
          return note.dueTime.isAfter(DateTime.now());
        case NoteState.completed:
          return note.dueTime.isBefore(DateTime.now());
        default:
          return true;
      }
    }).toList();

    if (widget.notesToShow == NoteState.completed) {
      notesToShow.sort((a, b) => b.creationTime.compareTo(a.creationTime));
      //notesToShow.sort((a, b) => b.dueTime.compareTo(a.dueTime));
      notesToShow = notesToShow.take(10).toList();
    } else {
      notesToShow.sort((a, b) => b.creationTime.compareTo(a.creationTime));
    }

    return Scaffold(
      floatingActionButton: !widget.showButtons ? null : _AddNoteButtons(
        textButton: _AddNoteButton(
          type: NoteType.textNote,
          onPress: () {
            _openOverlay(_getTextOverlay());
          },
          opacity: _textButtonOpacity,
        ),
        voiceButton: _AddNoteButton(
          type: NoteType.voiceNote,
          opacity: _voiceButtonOpacity,
          onPress: () async {
            if (!(await Record().hasPermission())) return;
            _openOverlay(_getRecordingOverlay());
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
    setState(() => _changeButtonsOpacity(0));

    await Navigator.push(context, PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => overlay
    ));

    setState(() => _changeButtonsOpacity(1));
  }

  void _addNote({String? audioPath, String? textContent, String? id, required DateTime dueTime}) {
    id ??= const Uuid().v4();

    final note = Note(
      id: id,
      dueTime: dueTime,
      recordingPath: audioPath,
      textContent: textContent,
      onDue: () => _onNotesUpdatedController.add(id),
    );

    note.saveToSharedPrefs();
    note.schedulePreRemindNotification(5);
    Alarm.setOneShot(dueTime, alarmCallback, note.numericId);
    _notes.add(note);
  }

  static void alarmCallback() {

  }

  Widget _getRecordingOverlay() {
    final String id = const Uuid().v4();
    return RecordingOverlay(
      onSuccessfullyFinished: (due, path) {
        setState(() {
          _addNote(dueTime: due, id: id, audioPath: path);
        });
      },
      recordingId: id,
    );
  }

  Widget _getTextOverlay() {
    return TextOverlay(
      onSuccessfullyFinished: (due, text) {
        setState(() {
          _addNote(dueTime: due, textContent: text);
        });
      },
    );
  }

  void _changeButtonsOpacity(double opacity) {
    _voiceButtonOpacity = opacity;
    _textButtonOpacity = opacity;
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
            onPressed: () {
              Vibration.vibrate(duration: 50);
              onPress?.call();
            },
            heroTag: type.toString(),
            child: Icon(type == NoteType.voiceNote
                ? Icons.record_voice_over
                : Icons.short_text_outlined),
          )
      )
    );
  }
}
