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
    return GarbageOverlay(
        body: Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      timeButton(timeToAdd: const Duration(minutes: 5)),
                      timeButton(timeToAdd: const Duration(minutes: 10)),
                      timeButton(timeToAdd: const Duration(minutes: 15)),
                    ],
                  )
                ),
                Expanded(
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        timeButton(timeToAdd: const Duration(minutes: 20)),
                        timeButton(timeToAdd: const Duration(minutes: 30)),
                        timeButton(timeToAdd: const Duration(minutes: 45)),
                      ],
                    )
                ),                Expanded(
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        timeButton(timeToAdd: const Duration(minutes: 60)),
                        timeButton(timeToAdd: const Duration(minutes: 120)),
                        timeButton(),
                      ],
                    )
                ),
              ],
            )
        )
    );
  }

  Widget timeButton({Duration? timeToAdd}) {
    return Expanded(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(12.0),
            ),
          ),
          height: double.infinity,
          margin: const EdgeInsets.all(8),
          child: TextButton(
            onPressed: () async {
              if (timeToAdd != null) {
                widget.onPicked(DateTime.now().add(timeToAdd));
                return;
              }

              var datetime = await pickTimeThroughTimePicker();
              if (datetime == null) return;
              widget.onPicked(datetime);
            },
            child: Text(timeToAdd != null ? "Za ${timeToAdd.inMinutes} minut" : "Vlastní"),
          ),
        )
    );
  }

  Future<DateTime?> pickTimeThroughTimePicker() async {
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