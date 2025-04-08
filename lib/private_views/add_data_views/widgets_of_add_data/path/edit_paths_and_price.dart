import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hesaplayici/services/database/firestore/constants.dart';
import 'package:hesaplayici/services/database/firestore/firestore_service.dart';
import 'package:hesaplayici/utilities/glass_effect.dart';

class EditPaths extends StatefulWidget {
  const EditPaths({super.key});

  @override
  State<EditPaths> createState() => _EditPathsState();
}

class _EditPathsState extends State<EditPaths> {
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _placePriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              tileMode: TileMode.clamp,
              transform: GradientRotation(1),
              colors: [
                Color.fromARGB(255, 0, 7, 100),
                Color.fromARGB(255, 102, 0, 133),
                Color.fromARGB(255, 0, 7, 100),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GlassEffect(
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                    ),
                  ),
                ],
              ),
              StreamBuilder(
                stream: FirestoreService().getAllPlace(
                  ownerUserId: FirebaseAuth.instance.currentUser?.uid,
                ),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allData = snapshot.data?.toList().reversed;
                        return Expanded(
                          child: ListView.builder(
                            itemCount: allData?.length,
                            itemBuilder: (context, index) {
                              return Slidable(
                                key: const ValueKey(0),
                                startActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      backgroundColor: Colors.purple,
                                      onPressed: (context) {
                                        _placeNameController.text =
                                            allData!.elementAt(index).placeName;
                                        _placePriceController.text = allData
                                            .elementAt(index)
                                            .placePrice
                                            .toString();
                                        addOrUpdate(
                                          context,
                                          _placeNameController,
                                          _placePriceController,
                                          true,
                                        );
                                      },
                                      foregroundColor: Colors.white,
                                      icon: Icons.update,
                                      label: 'Güncelle',
                                    )
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        FirestoreService().deletePlaceByName(
                                            placeName: allData!
                                                .elementAt(index)
                                                .placeName);
                                      },
                                      backgroundColor: const Color(0xFFFE4A49),
                                      foregroundColor: Colors.white,
                                      icon: Icons.delete,
                                      label: 'Sil',
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    '${allData?.elementAt(index).placeName}',
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  trailing: Text(
                                    '${allData?.elementAt(index).placePrice}',
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return const Expanded(
                          child: Center(child: Text('Veri yok')),
                        );
                      }
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GlassEffect(
                  child: IconButton(
                    onPressed: () {
                      addOrUpdate(
                        context,
                        _placeNameController,
                        _placePriceController,
                        false,
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> addOrUpdate(
    BuildContext context,
    TextEditingController placeName,
    TextEditingController placePrice,
    bool isUpdate,
  ) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                enabled: isUpdate ? false : true,
                controller: placeName,
                decoration: const InputDecoration(
                  labelText: 'Sefer yeri',
                ),
              ),
              TextFormField(
                controller: placePrice,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sefer tutarı',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (isUpdate) {
                    FirestoreService()
                        .updatePlaceByName(name: placeName.text, data: {
                      fieldPlacePrice: int.parse(placePrice.text),
                      fieldGUserId: FirebaseAuth.instance.currentUser!.uid,
                    });
                  } else {
                    FirestoreService().addPlace(data: {
                      fieldPlaceName: placeName.text.toUpperCase(),
                      fieldPlacePrice: int.parse(placePrice.text),
                      fieldGUserId: FirebaseAuth.instance.currentUser!.uid,
                    });
                  }
                  Navigator.pop(context); // Close the bottom sheet
                  placeName.text = '';
                  placePrice.text = '';
                },
                child: Text(isUpdate ? 'Güncelle' : 'Ekle'),
              ),
            ],
          ),
        );
      },
    );
  }
}
