import 'package:flutter/material.dart';

abstract class NoteOverlay extends StatefulWidget {
  final Function(DateTime dueTime, String data)? onSuccessfullyFinished;
  //final Function? onDismissed;
  final Function? onStartedPickingTime;

  const NoteOverlay({super.key, this.onSuccessfullyFinished, //this.onDismissed,
    this.onStartedPickingTime});
}

/*class _NoteOverlayState extends State<NoteOverlay> {
  bool pickingTime = false;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}*/
