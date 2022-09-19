import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();

/*    DefaultAssetBundle.of(context).load('assets/test_song.mp3').then((bytes) => {
      _player.setSourceBytes(bytes.buffer.asUint8List())
    });*/

    _player.setPlayerMode(PlayerMode.lowLatency);

    _player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });
    _player.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });
    _player.onPlayerStateChanged.listen((state) {
      setState(() {});
    });
  }

  String formatDuration(Duration duration) => duration.toString().split('.').first.substring(2);

  @override
  Widget build(BuildContext context) {
    String timeInfo = "${formatDuration(_position)}/${formatDuration(_duration)}";
    String buttonText;
    switch (_player.state) {
      case PlayerState.playing:
        buttonText = "Pause";
        break;
      case PlayerState.paused:
        buttonText = "Resume";
        break;
      case PlayerState.stopped:
      default:
        buttonText = "Play";
        break;
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: /*_duration.inSeconds == 0 ? null :*/ () => {
              _player.state == PlayerState.playing ? _player.stop() : _player.resume(),
            },
            child: Text(buttonText),
          ),
          const SizedBox(width: 10),
          Text(timeInfo)
        ]
    );
  }
}