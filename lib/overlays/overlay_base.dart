import 'package:flutter/material.dart';

// Superclass of all overlays.
abstract class OverlayBase extends StatefulWidget {
  final Function(DateTime dueTime, String data)? onSuccessfullyFinished;
  //final Function? onDismissed;
  final Function? onStartedPickingTime;

  const OverlayBase({super.key, this.onSuccessfullyFinished, //this.onDismissed,
    this.onStartedPickingTime});
}

/*class _NoteOverlayState extends State<NoteOverlay> {
  bool pickingTime = false;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}*/
