import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hesaplayici/models/voyage_model.dart';
import 'package:hesaplayici/services/database/firestore/firestore_service.dart';
import 'package:hesaplayici/utilities/glass_effect.dart';

class ShowTotals extends StatelessWidget {
  const ShowTotals({
    super.key,
    required this.frstDate,
    required this.lstDate,
    required this.plate,
  });

  final DateTime frstDate;
  final DateTime lstDate;
  final String plate;

  @override
  Widget build(BuildContext context) {
    int totalKm = 0;
    int totalPrice = 0;
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
              allData?.forEach((element) {
                totalPrice += int.parse(element.placePrice);
                totalKm =
                    (int.parse(element.endKm) - int.parse(element.startKm) < 0)
                        ? 0
                        : int.parse(element.endKm) - int.parse(element.startKm);
              });
              return GlassEffect(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text('Toplam KM'),
                          Text(
                            totalKm.toString(),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text('Toplam Tutar'),
                          Text(
                            totalPrice.toString(),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(
                child: Text('Veri bulunamadı'),
              );
            }

          default:
            return const Center(
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
              ),
            );
        }
      },
    );
  }
}
