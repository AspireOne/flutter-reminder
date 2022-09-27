import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

import 'base_note_overlay.dart';
import 'overlay.dart';

class RecordingOverlay extends NoteOverlay {

  const RecordingOverlay({Key? key, super.onSuccessfullyFinished, super.onStartedPickingTime, /*super.onDismissed*/}) : super(key: key);

  @override
  State<RecordingOverlay> createState() => _RecordingOverlayState();
}

class _RecordingOverlayState extends State<RecordingOverlay> {
  @override
  Widget build(BuildContext context) {
    return GarbageOverlay(
        body: Scaffold(
          backgroundColor: Colors.black.withOpacity(0),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _RecordingStopButton(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _RecordingOverlayMicIcon(),
                Text("6/10s", style: TextStyle(color: Colors.white)),
                Text("Listening...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        )
    );
  }
}

class _RecordingOverlayMicIcon extends StatelessWidget {
  const _RecordingOverlayMicIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      endRadius: 60.0,
      child: Material(
        elevation: 8.0,
        shape: const CircleBorder(),
        child: CircleAvatar(
          backgroundColor: Colors.grey[100],
          radius: 30.0,
          child: const Icon(Icons.mic),
        ),
      ),
    );
  }
}

class _RecordingStopButton extends StatefulWidget {
  final Function? onPress;
  const _RecordingStopButton({Key? key, this.onPress}) : super(key: key);

  @override
  State<_RecordingStopButton> createState() => _RecordingStopButtonState();
}

class _RecordingStopButtonState extends State<_RecordingStopButton> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      setState(() => opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          //splashColor: Colors.red,
          backgroundColor: Colors.red,
          onPressed: () => widget.onPress?.call(),
          child: const Icon(Icons.stop),
        )
    );
  }
}
