import 'package:flutter/material.dart';

class PullPersons extends StatefulWidget {
  final Stream stream;
  final Function(String selectedDriverId) sendDataToParent;

  const PullPersons(
      {super.key, required this.sendDataToParent, required this.stream});

  @override
  State<PullPersons> createState() => _PullPersonsState();
}

class _PullPersonsState extends State<PullPersons> {
  String? selectedDriver;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            if (snapshot.hasData) {
              final allData = snapshot.data?.toList().reversed;
              final bool isDriverInList =
                  allData!.map((e) => e.name).toList().contains(selectedDriver);

              // Create a list of DropdownMenuItem
              List<DropdownMenuItem<String>> dropdownItems = [];
              for (var data in allData) {
                dropdownItems.add(
                  DropdownMenuItem(
                    value: data.name,
                    child: Text(data.name),
                  ),
                );
              }

              return DropdownButton<String>(
                value: isDriverInList ? selectedDriver : null,
                items: dropdownItems,
                onChanged: (selectedValue) {
                  setState(() {
                    selectedDriver =
                        selectedValue; // Update selectedDriver afterwards
                  });
                  widget.sendDataToParent(
                    selectedValue!,
                  ); // Pass selectedValue directly
                },
                hint: const Text('Sürücü seç'),
              );
            } else {
              return DropdownButton(
                items: List.empty(),
                onChanged: (value) {},
              );
            }
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            return const Center(
              child: Text("Birşeyler ters gitti..."),
            );
        }
      },
    );
  }
}
