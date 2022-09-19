
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

    // Because playingStream doesn't send an event when the player is finished.
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) _player.stop();
    });
    _player.playingStream.listen((playing) => setState(() {
      _isPlaying = playing;
      // Otherwise the player doesn't seet back to zero automatically on stop.
      if (!_isPlaying) _player.seek(Duration.zero);
    }));
    _player.positionStream.listen((position) => setState(() => _position = position));
    _player.durationStream.listen((duration) => setState(() => _duration = duration ?? Duration.zero));
    _player.setUrl("//samplelib.com/lib/preview/mp3/sample-3s.mp3"); // Place the real production code here instead when the time comes.
  }

  @override
  Widget build(BuildContext context) {
    String timeInfo = "${formatDuration(_position)}/${formatDuration(_duration)}";
    final buttonText = _isPlaying ? "Stop" : "Play";

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: () => setState(() => _isPlaying ? _player.stop() : _player.play()),
            child: Text(buttonText),
          ),
          const SizedBox(width: 10),
          Text(timeInfo)
        ]
    );
  }

  String formatDuration(Duration duration) => duration.toString().split('.').first.substring(2);
}