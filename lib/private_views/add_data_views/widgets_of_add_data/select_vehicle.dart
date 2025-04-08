import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hesaplayici/models/vehicle_model.dart';
import 'package:hesaplayici/services/database/firestore/constants.dart';
import 'package:hesaplayici/services/database/firestore/firestore_service.dart';
import 'package:hesaplayici/utilities/glass_effect.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class SelectVehicleWidget extends StatefulWidget {
  final Function(String selectVehicle) sendDataToParent;
  final BuildContext scaffoldContext;

  const SelectVehicleWidget(
      {Key? key, required this.scaffoldContext, required this.sendDataToParent})
      : super(key: key);

  @override
  SelectVehicleWidgetState createState() => SelectVehicleWidgetState();
}

class SelectVehicleWidgetState extends State<SelectVehicleWidget> {
  String selectedVehicle = '';
  String selectedVehicleToRemove = ''; // New state variable
  String? plateName;

  @override
  Widget build(BuildContext context) {
    return GlassEffect(
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  isDismissible: true,
                  showDragHandle: true,
                  context: widget.scaffoldContext,
                  builder: (context) {
                    return SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          left: 16,
                          right: 16,
                          top: 16,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Yeni araç ekle',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 16,
                              width: double.maxFinite,
                            ),
                            TextField(
                              decoration:
                                  const InputDecoration(labelText: 'Plaka'),
                              onChanged: (value) {
                                setState(() {
                                  plateName = value.toUpperCase();
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                // prevent duplication
                                bool isDuplicate =
                                    await isThereSameVehicle(plateName!);
                                if (context.mounted) {
                                  if (isDuplicate) {
                                    showTopSnackBar(
                                      Overlay.of(context),
                                      const CustomSnackBar.error(
                                        message: "Araç zaten mevcut!",
                                      ),
                                    );
                                  } else {
                                    FirestoreService().addVehicle(
                                      data: {
                                        fieldGUserId: FirebaseAuth
                                            .instance.currentUser!.uid,
                                        fieldVhclePlate: plateName,
                                      },
                                    );
                                    if (context.mounted) {
                                      Navigator.pop(
                                          context); // Close the bottom sheet after saving
                                    }
                                  }
                                }
                              },
                              child: const Text('Kaydet'),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.add,
                color: Colors.green,
              ),
            ),
            getStreemToDropdown(),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  isDismissible: true,
                  showDragHandle: true,
                  context: widget.scaffoldContext,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                              left: 16,
                              right: 16,
                              top: 16,
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Araç sil',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  height: 16,
                                  width: double.maxFinite,
                                ),
                                getStreemToDropdownForRemove(setState),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      FirestoreService().deleteVehicleByName(
                                        plate: selectedVehicleToRemove,
                                      );
                                      selectedVehicleToRemove = '';
                                    });
                                  },
                                  child: const Text('Sil'),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.remove,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<Iterable<VehicleModel>> getStreemToDropdown() {
    return StreamBuilder(
      stream: FirestoreService().getAllVehicle(
        ownerUserId: FirebaseAuth.instance.currentUser?.uid,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            if (snapshot.hasData) {
              final allData = snapshot.data?.toList().reversed;
              final bool isVhclInList = allData!
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
                onChanged: (selectedValue) {
                  setState(() {
                    selectedVehicle =
                        selectedValue!; // Update selectedDriver afterwards
                    widget.sendDataToParent(selectedVehicle);
                  });
                },
                hint: const Text('Araç seç'),
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

  StreamBuilder<Iterable<VehicleModel>> getStreemToDropdownForRemove(
      var setState) {
    return StreamBuilder(
      stream: FirestoreService().getAllVehicle(
        ownerUserId: FirebaseAuth.instance.currentUser?.uid,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            final allData = snapshot.data?.toList().reversed;

            final bool isVhclInList = allData!
                .map((e) => e.plate)
                .toList()
                .contains(selectedVehicleToRemove);

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
              value: isVhclInList ? selectedVehicleToRemove : null,
              items: dropdownItems,
              onChanged: (selectedValue) {
                setState(() {
                  selectedVehicleToRemove =
                      selectedValue!; // Update selectedVehicleToRemove
                });
              },
              hint: const Text('Silmek için araç seç'),
            );
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

  Future<bool> isThereSameVehicle(String plate) async {
    final allData = await FirestoreService()
        .getAllVehicle(
          ownerUserId: FirebaseAuth.instance.currentUser?.uid,
        )
        .first; // Fetch the first result from the stream

    bool isDuplicate = false;
    for (var element in allData) {
      if (element.plate == plate) {
        isDuplicate = true;
        break;
      }
    }

    return isDuplicate;
  }
}
