import 'package:flutter/material.dart';
import 'package:flutter_reminder/overlays/garbage_overlay.dart';
import 'package:flutter_reminder/overlays/time_picker_overlay.dart';

class TextOverlay extends StatefulWidget {
  final Function(DateTime, String)? onSuccessfullyFinished;

  const TextOverlay({Key? key, this.onSuccessfullyFinished}) : super(key: key);

  @override
  State<TextOverlay> createState() => _TextOverlayState();
}

class _TextOverlayState extends State<TextOverlay> {
  bool textInserted = false;
  String? text;

  @override
  Widget build(BuildContext context) {
    return GarbageOverlay(
      body: Dialog(
        child: textInserted
            ? TimePickerOverlay(onPicked: (time) {
              widget.onSuccessfullyFinished!(time, text!);
              Navigator.pop(context);
            })
            : TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Note',
          ),
          onSubmitted: (value) {
            setState(() {
              text = value;
              textInserted = true;
            });
          },
        ),
      ),
    );
  }
}
