import 'package:flutter/material.dart';

// The parent of all overlays. Don't question the name.
class GarbageOverlay extends StatefulWidget {
  final Widget body;
  final Function? onDismissed;

  const GarbageOverlay({Key? key, required this.body, this.onDismissed}) : super(key: key);

  @override
  State<GarbageOverlay> createState() => _GarbageOverlayState();
}

class _GarbageOverlayState extends State<GarbageOverlay> {
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => setState(() => opacity = 1));
  }

  // TODO: Add universal cancel button.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onDismissed?.call();
        Navigator.pop(context);
      },
      child: Container(
          padding: const EdgeInsets.all(32),
          height: double.infinity,
          color: const Color.fromRGBO(0, 0, 0, 0.7),
          width: double.infinity,
          child: AnimatedOpacity(
              opacity: opacity,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
              child: widget.body
          )
      ),
    );
  }
}
