import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hesaplayici/private_views/voyage_menu/show_totals.dart';
import 'package:hesaplayici/services/database/firestore/firestore_service.dart';
import 'package:hesaplayici/utilities/glass_effect.dart';
import 'package:intl/intl.dart';

import 'list_view_items/expanded_item.dart';

class VoyageMenu extends StatefulWidget {
  const VoyageMenu({super.key});

  @override
  State<VoyageMenu> createState() => _VoyageMenuState();
}

class _VoyageMenuState extends State<VoyageMenu> {
  int totalKm = 0;
  int totalPrice = 0;

  DateTime firstDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  DateTime lastDate = DateTime.now().add(const Duration(hours: 6));
  final ownerUserId = FirebaseAuth.instance.currentUser!.uid;
  String selectedVehicle = '';
  Map<String, int> totals = {};
  bool isSelected = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isSelected = !isSelected;
            });
          },
          child: AnimatedContainer(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: isSelected ? Colors.transparent : Colors.transparent,
            ),
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 50.0 : double.maxFinite,
            height: isSelected ? 20.0 : 50,
            alignment:
                isSelected ? Alignment.center : AlignmentDirectional.topCenter,
            child: isSelected
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                    child: const Icon(
                      Icons.expand_more,
                      color: Colors.purple,
                    ),
                  )
                : FittedBox(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // filter by vehicle (dropdown)
                        GlassEffect(
                          child: StreamBuilder(
                            stream: FirestoreService().getAllVehicle(
                              ownerUserId:
                                  FirebaseAuth.instance.currentUser?.uid,
                            ),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.active:
                                  final allData =
                                      snapshot.data?.toList().reversed;
                                  if (allData == null) {
                                    return TextButton(
                                        onPressed: () {},
                                        child: const Text('No data'));
                                  } else {
                                    final bool isVhclInList = allData
                                        .map((e) => e.plate)
                                        .toList()
                                        .contains(selectedVehicle);
                                    // Create a list of DropdownMenuItem
                                    List<DropdownMenuItem<String>>
                                        dropdownItems = [];
                                    for (var data in allData) {
                                      dropdownItems.add(
                                        DropdownMenuItem(
                                          value: data.plate,
                                          child: Text(data.plate),
                                        ),
                                      );
                                    }

                                    return DropdownButton<String>(
                                      value:
                                          isVhclInList ? selectedVehicle : null,
                                      items: dropdownItems,
                                      alignment: Alignment.center,
                                      underline: const SizedBox.shrink(),
                                      onChanged: (selectedValue) {
                                        setState(() {
                                          selectedVehicle = selectedValue!;
                                        });
                                      },
                                      hint: const Text('Select a vehicle'),
                                    );
                                  }

                                case ConnectionState.waiting:
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                default:
                                  return const Center(
                                    child: Text("Something went wrong..."),
                                  );
                              }
                            },
                          ),
                        ),
                        // filter by date (button)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isSelected = !isSelected;
                            });
                          },
                          icon: const Icon(Icons.keyboard_arrow_up_outlined),
                        ),
                        GlassEffect(
                          child: GestureDetector(
                            onTap: () async {
                              var a = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(1997, 5, 19),
                                lastDate: DateTime(2099, 5, 19),
                              );
                              setState(() {
                                firstDate = a?.start ??
                                    DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                    );
                                lastDate = a?.end.add(
                                      const Duration(
                                          hours: 23, minutes: 59, seconds: 59),
                                    ) ??
                                    DateTime.now();
                              });
                            },
                            child: Row(
                              children: [
                                Text(
                                  DateFormat('dd.MM.yyyy').format(firstDate),
                                ),
                                const Text(
                                  " - ",
                                  style: TextStyle(
                                      color: Colors.purple, fontSize: 34),
                                ),
                                Text(DateFormat('dd.MM.yyyy').format(lastDate)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        ExpandItem(
          frstDate: firstDate,
          lstDate: lastDate,
          plate: selectedVehicle,
        ),
        ShowTotals(
          frstDate: firstDate,
          lstDate: lastDate,
          plate: selectedVehicle,
        )
      ],
    );
  }
}
