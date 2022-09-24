import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class RecordingOverlay extends StatefulWidget {
  final Function(String audioPath, DateTime dueTime) onFinished;

  const RecordingOverlay({Key? key, required this.onFinished}) : super(key: key);

  @override
  State<RecordingOverlay> createState() => _RecordingOverlayState();
}

class _RecordingOverlayState extends State<RecordingOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        color: const Color.fromRGBO(0, 0, 0, 0.7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _RecordingOverlayMicIcon(),
            Text("6/10s"),
            Text("Listening...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ],
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