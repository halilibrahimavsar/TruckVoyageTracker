import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hesaplayici/models/voyage_model.dart';
import 'package:hesaplayici/private_views/add_data_views/add_or_update_voyage.dart';
import 'package:hesaplayici/services/database/firestore/constants.dart';
import 'package:hesaplayici/services/database/firestore/firestore_service.dart';
import 'package:hesaplayici/utilities/glass_effect.dart';
import 'package:hesaplayici/utilities/show_custm_dialog.dart';
import 'package:intl/intl.dart';

class ExpandItem extends StatelessWidget {
  final DateTime frstDate;
  final DateTime lstDate;
  final String plate;

  const ExpandItem({
    super.key,
    required this.frstDate,
    required this.lstDate,
    required this.plate,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirestoreService().getVoyageByDate(
        plate: plate,
        firstDate: Timestamp.fromDate(frstDate),
        lastDate: Timestamp.fromDate(lstDate),
        ownerUserId: FirebaseAuth.instance.currentUser?.uid,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            if (snapshot.hasData) {
              final Iterable<VoyageModel>? allData =
                  snapshot.data?.toList().reversed;
              return Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: allData!.length,
                        itemBuilder: (context, index) {
                          final data = allData.elementAt(index);

                          int totalKm = (int.parse(data.endKm) -
                                      int.parse(data.startKm) <
                                  0)
                              ? 0
                              : int.parse(data.endKm) - int.parse(data.startKm);
                          bool isVoyageFinished =
                              totalKm != 0 && int.parse(data.placePrice) != 0;

                          return Slidable(
                            startActionPane: ActionPane(
                              // A motion is a widget used to control how the pane animates.
                              motion: const ScrollMotion(),
                              extentRatio: 0.30,

                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    showCustmDialog(
                                      context,
                                      title: 'Delete',
                                      msg: 'Do you want to delete this item?',
                                      cancelButton: 'No',
                                      confirmButton: 'Yes, delete',
                                      confirmButtonColor: Colors.red,
                                      cancelButtonColor: Colors.green,
                                      functionWhenConfirm: () async {
                                        await FirestoreService().deleteVoyage(
                                          id: allData.elementAt(index).id,
                                        );
                                      },
                                      functionWhenCancel: () {},
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  backgroundColor: const Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.30,
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) {
                                        return AddOrUpdateVoyage(
                                          scaffoldContext: context,
                                          existingData: {
                                            fieldVoygeStartkm: data.startKm,
                                            fieldVoygeEndKm: data.endKm,
                                            fieldVoygePlace: data.placeName,
                                            fieldVoygePrice: data.placePrice,
                                            fieldVoygeDrvr: data.driver,
                                            fieldVoygeVehicle: data.vehicle,
                                            fieldVoygeDepartureDate:
                                                data.startDate,
                                            fieldVoygeReturnDate: data.endDate,
                                            'voyageId': data.id,
                                          },
                                        ); // add optional parameter
                                      },
                                    ));
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  backgroundColor:
                                      const Color.fromARGB(255, 114, 0, 135),
                                  foregroundColor: Colors.white,
                                  icon: Icons.update,
                                  label: 'Update',
                                ),
                              ],
                            ),
                            child: GlassEffect(
                              child: expandedDetails(
                                  index, isVoyageFinished, totalKm, data),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('No data found'),
              );
            }

          default:
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
        }
      },
    );
  }

  ExpansionTile expandedDetails(
    int index,
    bool isVoyageFinished,
    int totalKm,
    VoyageModel data,
  ) {
    return ExpansionTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('${index + 1}'),
          const [
            Icon(
              Icons.check,
              color: Colors.green,
            ),
            Icon(
              Icons.circle,
              color: Colors.yellow,
            ),
          ][isVoyageFinished ? 0 : 1],
        ],
      ),
      title: FittedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  totalKm.toString(),
                  style: const TextStyle(
                    color: Colors.green,
                  ),
                ),
                const Text(
                  ' Km',
                  style: TextStyle(fontSize: 8),
                ),
              ],
            ),
            const SizedBox(width: 32),
            Text(
              DateFormat('dd/MM/yyyy').format(data.startDate),
            ),
            const SizedBox(width: 32),
            Text(
              '${data.placePrice} ₺',
              style: const TextStyle(
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            blackedBackground(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      blackedBackground(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Baslangıc km:'),
                            Text(
                              data.startKm,
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      blackedBackground(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Bitis km :'),
                            Text(
                              data.endKm,
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            blackedBackground(
              child: Column(
                children: [
                  blackedBackground(
                    child: Column(
                      children: [
                        const Text('Başlangıc tarihi'),
                        Text(
                          DateFormat('yyyy.MM.d - HH:mm')
                              .format(data.startDate),
                          style: const TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  blackedBackground(
                    child: Column(
                      children: [
                        const Text('Bitiş tarihi'),
                        Text(
                          DateFormat('yyyy.MM.d - HH:mm').format(data.endDate),
                          style: const TextStyle(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox.fromSize(
          size: const Size(300, 50),
          child: blackedBackground(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Sefer yeri : '),
                Text(
                  data.placeName,
                  style: const TextStyle(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container blackedBackground({child}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent.withOpacity(0.2),
        border: Border.all(color: Colors.grey),
      ),
      child: child,
    );
  }
}
