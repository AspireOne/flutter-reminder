
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class VoiceNoteContent extends StatefulWidget {
  final String audioPath;
  const VoiceNoteContent({Key? key, required this.audioPath}) : super(key: key);

  @override
  VoiceNoteContentState createState() => VoiceNoteContentState();
}

class VoiceNoteContentState extends State<VoiceNoteContent> {
  final _player = AudioPlayer();
  Duration _duration = const Duration();
  Duration _position = const Duration();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _player.positionStream.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    _player.durationStream.listen((duration) {
      if (mounted) setState(() => _duration = duration ?? Duration.zero);
    });

    // Because playingStream doesn't send an event when the player is finished.
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) _player.stop();
    });
    _player.playingStream.listen((playing) {
      if (!mounted) return;
      // Otherwise the player doesn't seet back to zero automatically on stop.
      setState(() {if (!(_isPlaying = playing)) _player.seek(Duration.zero);});
    });
    _player.setFilePath(widget.audioPath, preload: false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeInfo = "${formatDuration(_position)}/${formatDuration(_duration)}";
    final buttonText = _isPlaying ? "Stop" : "Play";

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () => setState(() {
              _isPlaying ? _player.stop() : _player.play();
            }),
            child: Text(buttonText),
          ),
          const SizedBox(width: 10),
          Text(timeInfo)
        ]
    );
  }

  String formatDuration(Duration duration) => duration.toString().split('.').first.substring(2);
}