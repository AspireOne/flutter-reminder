import 'package:flutter/material.dart';

import 'garbage_overlay.dart';

class TimePickerOverlay extends StatefulWidget {
  final Function(DateTime time) onPicked;
  const TimePickerOverlay({Key? key, required this.onPicked}) : super(key: key);

  @override
  State<TimePickerOverlay> createState() => _TimePickerOverlayState();
}

class _TimePickerOverlayState extends State<TimePickerOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TimeButton(timeToAdd: const Duration(minutes: 5), onPicked: widget.onPicked),
                TimeButton(timeToAdd: const Duration(minutes: 10), onPicked: widget.onPicked),
                TimeButton(timeToAdd: const Duration(minutes: 15), onPicked: widget.onPicked),
              ],
            ),
            Row(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TimeButton(timeToAdd: const Duration(minutes: 20), onPicked: widget.onPicked),
                TimeButton(timeToAdd: const Duration(minutes: 30), onPicked: widget.onPicked),
                TimeButton(timeToAdd: const Duration(minutes: 45), onPicked: widget.onPicked),
              ],
            ),
            Row(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TimeButton(timeToAdd: const Duration(minutes: 60), onPicked: widget.onPicked),
                TimeButton(timeToAdd: const Duration(minutes: 120), onPicked: widget.onPicked),
                TimeButton(onPicked: widget.onPicked),
              ],
            ),
          ],
        )
    );
  }
}

class TimeButton extends StatelessWidget {
  final Duration? timeToAdd;
  final Function(DateTime time) onPicked;
  
  const TimeButton({Key? key, this.timeToAdd, required this.onPicked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            ),
          ),
          height: 100,
          margin: const EdgeInsets.all(8),
          child: _getButton(context),
        )
    );
  }

  TextButton _getButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
        if (timeToAdd != null) {
          onPicked(DateTime.now().add(timeToAdd!));
          return;
        }
        var datetime = await pickTimeThroughTimePicker(context);
        if (datetime == null) return;
        onPicked(datetime);
      },
      child: Text(timeToAdd != null ? "Za ${timeToAdd!.inMinutes} minut" : "Vlastní"),
    );
  }

  Future<DateTime?> pickTimeThroughTimePicker(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (timeOfDay == null) return null;
    DateTime datetime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        timeOfDay.hour,
        timeOfDay.minute
    );

    if (datetime.isBefore(DateTime.now())) datetime = datetime.add(const Duration(days: 1));
    return datetime;
  }
}
