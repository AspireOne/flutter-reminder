import 'package:flutter/material.dart';
import 'package:flutter_reminder/overlays/garbage_overlay.dart';

import 'overlay_base.dart';

class TextOverlay extends OverlayBase {
  const TextOverlay({Key? key, super.onSuccessfullyFinished, super.onStartedPickingTime, /*super.onDismissed*/}) : super(key: key);

  @override
  State<TextOverlay> createState() => _TextOverlayState();
}

class _TextOverlayState extends State<TextOverlay> {
  @override
  Widget build(BuildContext context) {
    return GarbageOverlay(body: Container());
  }
}
