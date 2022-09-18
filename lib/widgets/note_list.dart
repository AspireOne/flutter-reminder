import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'note.dart';

class NoteList extends StatelessWidget {
  final List<Note>? notes;
  final String noNotesMessage;

  const NoteList({Key? key, this.notes, this.noNotesMessage = "No notes."}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notes == null || notes!.isEmpty) {
      return Center(
          child: Text(
              noNotesMessage,
              textAlign: TextAlign.center
          )
      );
    }

    return ImplicitlyAnimatedList<Note>(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 128),
      items: notes!,
      areItemsTheSame: (a, b) => a.id == b.id,
      itemBuilder: (context, animation, item, index) {
        return SizeFadeTransition(
          sizeFraction: 0.7,
          curve: Curves.easeInOut,
          animation: animation,
          child: item,
        );
      },
      removeItemBuilder: (context, animation, oldItem) {
        return FadeTransition(
          opacity: animation,
          child: oldItem,
        );
      },
    );
  }
}