import 'package:flutter/material.dart';

class TextOverlay extends StatefulWidget {
  final Function(String text, DateTime dueTime) onFinished;

  const TextOverlay({Key? key, required this.onFinished}) : super(key: key);

  @override
  State<TextOverlay> createState() => _TextOverlayState();
}

class _TextOverlayState extends State<TextOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
