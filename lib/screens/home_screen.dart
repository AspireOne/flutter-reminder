import 'package:flutter/material.dart';

import '../overlays/time_picker_overlay.dart';
import '../widgets/note_list_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: const TabBarView(
            children: [
              TimePickerOverlay()
              /*NoteListTab(notesToShow: NoteState.oncoming),
              NoteListTab(notesToShow: NoteState.completed),*/
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