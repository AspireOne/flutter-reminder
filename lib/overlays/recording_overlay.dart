import 'dart:async';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reminder/overlays/time_picker_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'garbage_overlay.dart';

class RecordingOverlay extends StatefulWidget {
  final String recordingId;
  final Function(DateTime, String)? onSuccessfullyFinished;

  const RecordingOverlay({Key? key, required this.recordingId, this.onSuccessfullyFinished}) : super(key: key);

  @override
  State<RecordingOverlay> createState() => _RecordingOverlayState();
}

class _RecordingOverlayState extends State<RecordingOverlay> {
  final Record recorder = Record();
  final Duration maxDuration = const Duration(seconds: 10);
  bool hasFinishedRecording = false;
  Duration elapsed = Duration.zero;
  String path = "";

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((value) {
      path = "${value.path}/recordings/${widget.recordingId}.mp3";
      startRecording();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GarbageOverlay(
        body: hasFinishedRecording
            ? TimePickerOverlay(onPicked: (time) {
                widget.onSuccessfullyFinished!(time, path);
                Navigator.pop(context);
            })
            : getRecordingWidget(maxDuration, elapsed)
    );
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
            const SizedBox(
              height: 20,
            ),
            const Text("Listening...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  void startRecording() async {
    if (await recorder.isRecording()) return;

    recorder.start(path: path);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (elapsed >= maxDuration || hasFinishedRecording || !mounted) {
        timer.cancel();
        stopRecording();
        return;
      }
      setState(() => elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    stopRecording();
    super.dispose();
  }

  void stopRecording() async {
    if (!await recorder.isRecording()) return;

    recorder.stop();
    recorder.dispose();
    setState(() => hasFinishedRecording = true);
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
