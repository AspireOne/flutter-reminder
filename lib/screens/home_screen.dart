import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/note_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
    );
  }
}