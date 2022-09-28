import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import 'overlay_base.dart';
import 'garbage_overlay.dart';

class RecordingOverlay extends OverlayBase {
  final String recordingId;

  const RecordingOverlay({Key? key, required this.recordingId, super.onSuccessfullyFinished, super.onStartedPickingTime, /*super.onDismissed*/}) : super(key: key);

  @override
  State<RecordingOverlay> createState() => _RecordingOverlayState();
}

class _RecordingOverlayState extends State<RecordingOverlay> {
  final Record recorder = Record();
  final Duration maxRecordingDuration = const Duration(seconds: 10);
  Duration recordingElapsed = Duration.zero;
  bool recording = true;

  @override
  void initState() {
    super.initState();
    recorder.start(
      path: "recording_${widget.recordingId}.m4a",
    );

    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => recordingElapsed += const Duration(seconds: 1));
      if (recordingElapsed >= maxRecordingDuration) {
        timer.cancel();
        stopRecording();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GarbageOverlay(
        body: recording ? getRecordingWidget(maxRecordingDuration, recordingElapsed) : getTimePickerWidget()
    );
  }

  Widget getTimePickerWidget() {
    return Container();
  }

  Widget getRecordingWidget(Duration duration, Duration elapsed) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _RecordingStopButton(
        onPress: () {
          stopRecording();
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _RecordingOverlayMicIcon(),
            Text("${elapsed.inSeconds}/${duration.inSeconds}s", style: const TextStyle(color: Colors.white)),
            const Text("Listening...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  void stopRecording() async {
    if (!await recorder.isRecording()) return;
    recorder.stop();
    recorder.dispose();
    setState(() => recording = false);
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
