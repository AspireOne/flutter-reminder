import 'package:flutter/material.dart';

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
              NoteListTab(tabType: TabType.ongoingNotes),
              NoteListTab(tabType: TabType.notesHistory),
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