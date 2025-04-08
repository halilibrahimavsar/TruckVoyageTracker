import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:hesaplayici/utilities/glass_effect.dart';

class SelectDateWidget extends StatefulWidget {
  final Function(DateTime departureD, DateTime returnD) sendDatesToParent;

  const SelectDateWidget({
    super.key,
    required this.sendDatesToParent,
  });

  @override
  State<SelectDateWidget> createState() => _SelectDateWidgetState();
}

class _SelectDateWidgetState extends State<SelectDateWidget> {
  late DateTime departureDate;
  late DateTime returnDate;

  @override
  void initState() {
    departureDate = DateTime.now();
    returnDate = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GlassEffect(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GlassEffect(
              child: Column(
                children: [
                  const Text('Başlangıç Tarihi'),
                  DateTimePicker(
                    type: DateTimePickerType.dateTimeSeparate,
                    dateMask: 'd - MM - yyyy',
                    initialValue: DateTime.now().toString(),
                    firstDate: DateTime(1997),
                    lastDate: DateTime(2100),
                    icon: const Icon(Icons.event),
                    calendarTitle: "Başlangıç Tarihi",
                    use24HourFormat: true,
                    dateLabelText: 'Tarih',
                    timeLabelText: "Saat",
                    onChanged: (value) {
                      departureDate = DateTime.parse(value);
                      widget.sendDatesToParent(departureDate, returnDate);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GlassEffect(
              child: Column(
                children: [
                  const Text('Bitiş Tarihi'),
                  DateTimePicker(
                    type: DateTimePickerType.dateTimeSeparate,
                    dateMask: 'd - MM - yyyy',
                    initialValue: DateTime.now().toString(),
                    firstDate: DateTime(1997),
                    lastDate: DateTime(2100),
                    icon: const Icon(Icons.event),
                    calendarTitle: "Bitiş Tarihi",
                    use24HourFormat: true,
                    dateLabelText: 'Tarih',
                    timeLabelText: "Saat",
                    onChanged: (value) {
                      returnDate = DateTime.parse(value);
                      widget.sendDatesToParent(departureDate, returnDate);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
