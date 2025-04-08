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
  DateTime firstDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  DateTime lastDate = DateTime.now().add(const Duration(hours: 6));
  String selectedVehicle = '';
  bool isFilterButtonHiding = true;
  bool isShowingUnfinishedVoyages = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isFilterButtonHiding = !isFilterButtonHiding;
            });
          },
          child: AnimatedContainer(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: isFilterButtonHiding
                  ? Colors.transparent
                  : Colors.transparent,
            ),
            duration: const Duration(milliseconds: 300),
            width: isFilterButtonHiding ? 50.0 : double.maxFinite,
            height: isFilterButtonHiding ? 20.0 : 140,
            alignment: isFilterButtonHiding
                ? Alignment.center
                : AlignmentDirectional.topCenter,
            child: isFilterButtonHiding
                ? _filterHideBut()
                : _showFilteredData(context),
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

  FittedBox _showFilteredData(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: GlassEffect(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Tamamlanmayan seferleri göster'),
                Switch(
                  value: isShowingUnfinishedVoyages,
                  onChanged: (value) {
                    setState(() {
                      isShowingUnfinishedVoyages = value;
                      firstDate = isShowingUnfinishedVoyages
                          ? DateTime(DateTime.now().year)
                          : DateTime.now();

                      lastDate = isShowingUnfinishedVoyages
                          ? DateTime.now().add(const Duration(hours: 6))
                          : DateTime.now();
                      selectedVehicle = '';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 2,
              width: 300,
              child: ColoredBox(color: Colors.grey),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // filter by vehicle (dropdown)
                GlassEffect(
                  child: StreamBuilder(
                    stream: FirestoreService().getAllVehicle(
                      ownerUserId: FirebaseAuth.instance.currentUser?.uid,
                    ),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.active:
                          final allData = snapshot.data?.toList().reversed;
                          if (allData == null) {
                            return const Text('Veri yok');
                          } else {
                            final bool isVhclInList = allData
                                .map((e) => e.plate)
                                .toList()
                                .contains(selectedVehicle);
                            // Create a list of DropdownMenuItem
                            List<DropdownMenuItem<String>> dropdownItems = [];
                            for (var data in allData) {
                              dropdownItems.add(
                                DropdownMenuItem(
                                  value: data.plate,
                                  child: Text(data.plate),
                                ),
                              );
                            }

                            return DropdownButton<String>(
                              value: isVhclInList ? selectedVehicle : null,
                              items: dropdownItems,
                              alignment: Alignment.center,
                              underline: const SizedBox.shrink(),
                              onChanged: (selectedValue) {
                                setState(() {
                                  selectedVehicle = selectedValue!;
                                  isShowingUnfinishedVoyages = false;
                                });
                              },
                              hint: const Text('Araç seç'),
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
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      isFilterButtonHiding = !isFilterButtonHiding;
                      isShowingUnfinishedVoyages = false;
                    });
                  },
                  icon: const Icon(Icons.keyboard_arrow_up_outlined),
                ),
                // filter by date (button)
                GlassEffect(
                  child: GestureDetector(
                    onTap: () async {
                      var selectedDateRange = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(1997, 5, 19),
                        lastDate: DateTime(2099, 5, 19),
                      );
                      setState(() {
                        firstDate = selectedDateRange?.start ??
                            DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                            );
                        lastDate = selectedDateRange?.end.add(
                              const Duration(
                                  hours: 23, minutes: 59, seconds: 59),
                            ) ??
                            DateTime.now();
                        isShowingUnfinishedVoyages = false;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          DateFormat('dd.MM.yyyy').format(firstDate),
                        ),
                        const Text(
                          " - ",
                          style: TextStyle(color: Colors.purple, fontSize: 34),
                        ),
                        Text(DateFormat('dd.MM.yyyy').format(lastDate)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _filterHideBut() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFilterButtonHiding = !isFilterButtonHiding;
        });
      },
      child: const Icon(
        Icons.expand_more,
        color: Colors.purple,
      ),
    );
  }
}
