
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

  @override
  void initState() {
    super.initState();

/*    DefaultAssetBundle.of(context).load('assets/test_song.mp3').then((bytes) => {
      _player.setSourceBytes(bytes.buffer.asUint8List())
    });*/

    _player.positionStream.listen((position) {
      setState(() => _position = position);
    });
    _player.playerStateStream.listen((playerState) {
      setState((){});
    });
    _player.durationStream.listen((duration) {
      setState(() => _duration = duration ?? const Duration());
    });
  }

  String formatDuration(Duration duration) => duration.toString().split('.').first.substring(2);

  @override
  Widget build(BuildContext context) {
    String timeInfo = "${formatDuration(_position)}/${formatDuration(_duration)}";
    String buttonText;
    switch (_player.playerState.playing) {
      case true:
        buttonText = "Stop";
        break;
      case false:
      default:
        buttonText = "Play";
        break;
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: /*_duration.inSeconds == 0 ? null :*/ () => {
              _player.playerState.playing ? _player.stop() : _player.play(),
            },
            child: Text(buttonText),
          ),
          const SizedBox(width: 10),
          Text(timeInfo)
        ]
    );
  }
}