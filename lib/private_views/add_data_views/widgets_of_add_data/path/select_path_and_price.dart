import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hesaplayici/models/place_model.dart';
import 'package:hesaplayici/private_views/add_data_views/widgets_of_add_data/path/edit_paths_and_price.dart';
import 'package:hesaplayici/services/database/firestore/firestore_service.dart';
import 'package:hesaplayici/utilities/glass_effect.dart';

class SelectPath extends StatefulWidget {
  final Function(String slctdVal, int price) sendDataToParent;
  const SelectPath({super.key, required this.sendDataToParent});

  @override
  State<SelectPath> createState() => _SelectPathState();
}

class _SelectPathState extends State<SelectPath> {
  String placeName = '';
  int placePrice = 0;
  @override
  Widget build(BuildContext context) {
    return GlassEffect(
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const EditPaths();
                },
              ));
            },
            icon: const Icon(Icons.edit),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirestoreService().getAllPlace(
                ownerUserId: FirebaseAuth.instance.currentUser?.uid,
              ),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.active:
                    final Iterable<PlaceModel> allData =
                        snapshot.data?.toList().reversed ?? [];

                    List<List<dynamic>> dropdownItems = [];
                    for (var data in allData) {
                      // dropdownItems.add('${data.placeName} : ${data.placePrice}');
                      dropdownItems.add([data.placeName, data.placePrice]);
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownSearch(
                        popupProps: const PopupProps.bottomSheet(
                          title: Text('Sefer ara'),
                          showSearchBox: true,
                        ),
                        dropdownDecoratorProps: const DropDownDecoratorProps(),
                        selectedItem: [placeName, placePrice],
                        itemAsString: (item) {
                          return '${item[0]}    : [${item[1]} TL]';
                        },
                        dropdownButtonProps: const DropdownButtonProps(),
                        dropdownBuilder: (context, selectedItem) {
                          return selectedItem[0].isEmpty
                              ? const Text('')
                              : Text(
                                  '${selectedItem?[0]}  =  [${selectedItem?[1]} TL]',
                                  textAlign: TextAlign.center,
                                );
                        },
                        items: dropdownItems,
                        onChanged: (value) {
                          placeName = value![0];
                          placePrice = value[1];
                          widget.sendDataToParent(
                            value[0],
                            value[1],
                          );
                        },
                      ),
                    );
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );

                  default:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
