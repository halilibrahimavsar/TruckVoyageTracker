import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesaplayici/utilities/glass_effect.dart';
import 'package:intl/intl.dart';

class SelectKmWidget extends StatefulWidget {
  final Function(int startKm, int endKm, int totalKm) sendDataToParent;
  final String? startKm;
  final String? endKm;
  const SelectKmWidget(
      {super.key, required this.sendDataToParent, this.startKm, this.endKm});

  @override
  SelectKmWidgetState createState() => SelectKmWidgetState();
}

class SelectKmWidgetState extends State<SelectKmWidget> {
  late TextEditingController _startKm;
  late TextEditingController _endKm;
  int totalKm = 0;

  @override
  void initState() {
    if (widget.endKm != null || widget.startKm != null) {
      _startKm = TextEditingController();
      _endKm = TextEditingController();
      _startKm.text = widget.startKm!;
      _endKm.text = widget.endKm!;
      totalKm = int.parse(_endKm.text) - int.parse(_startKm.text);
    } else {
      _startKm = TextEditingController();
      _endKm = TextEditingController();
    }

    super.initState();
  }

  @override
  void dispose() {
    _startKm.dispose();
    _endKm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    return GlassEffect(
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _startKm,
                    textAlign: TextAlign.center,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field can\'t be empty';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _validateAndSendDataToParent();
                    },
                    decoration: const InputDecoration(labelText: 'start km'),
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _endKm,
                    textAlign: TextAlign.center,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (int.tryParse(_startKm.text) != null) {
                        if (value == null || value.isEmpty) {
                          return 'This field can\'t be empty';
                        } else if (int.parse(value) <
                            int.parse(_startKm.text)) {
                          return 'end is less then start km';
                        }
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _validateAndSendDataToParent();
                    },
                    decoration: const InputDecoration(labelText: 'end km'),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Total km : ${numberFormat.format(totalKm)}"),
          ),
        ],
      ),
    );
  }

  void _validateAndSendDataToParent() {
    setState(() {
      final start = int.tryParse(_startKm.text) ?? 0;
      final end = int.tryParse(_endKm.text) ?? 0;
      totalKm = (end - start < 0) ? 0 : end - start;
      widget.sendDataToParent(start, end, totalKm);
    });
  }
}
