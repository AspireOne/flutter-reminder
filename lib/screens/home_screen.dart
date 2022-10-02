import 'package:flutter/material.dart';

import '../overlays/time_picker_overlay.dart';
import '../widgets/note_list_tab.dart';

class HomeScreen extends StatelessWidget {
  final String? payload;
  const HomeScreen({Key? key, this.payload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: const TabBarView(
            children: [
              NoteListTab(notesToShow: NoteState.oncoming, showButtons: true,),
              NoteListTab(notesToShow: NoteState.completed, showButtons: false),
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
    );
  }
}