import 'package:flutter/material.dart';

import 'garbage_overlay.dart';

class TimePickerOverlay extends StatefulWidget {
  const TimePickerOverlay({Key? key}) : super(key: key);

  @override
  State<TimePickerOverlay> createState() => _TimePickerOverlayState();
}

class _TimePickerOverlayState extends State<TimePickerOverlay> {
  @override
  Widget build(BuildContext context) {
    return GarbageOverlay(
        body: Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () {}, // Handle your callback
                      child: Ink(color: Colors.transparent),
                    ),
                    InkWell(
                      onTap: () {}, // Handle your callback
                      child: Ink(color: Colors.transparent),
                    ),
                    InkWell(
                      onTap: () {}, // Handle your callback
                    )
                  ],
                )
              ],
            )
        )
    );
  }
}

class TimeButton extends StatelessWidget {
  const TimeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

