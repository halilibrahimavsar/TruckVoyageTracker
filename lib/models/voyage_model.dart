import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hesaplayici/services/database/firestore/constants.dart';

class VoyageModel {
  final String id;
  final String userId;
  final String startKm;
  final String endKm;
  final String placeName;
  final String placePrice;
  final String driver;
  final String vehicle;
  final DateTime startDate;
  final DateTime endDate;

  VoyageModel(this.id, this.userId, this.startKm, this.endKm, this.placeName,
      this.placePrice, this.driver, this.vehicle, this.startDate, this.endDate);

  VoyageModel.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot
            .id, // pull the autogenerated document id (DocumentId) from firestore.
        userId = snapshot.data()[fieldGUserId],
        startKm = snapshot.data()[fieldVoygeStartkm].toString(),
        endKm = snapshot.data()[fieldVoygeEndKm].toString(),
        placeName = snapshot.data()[fieldVoygePlace],
        placePrice = snapshot.data()[fieldVoygePrice].toString(),
        driver = snapshot.data()[fieldVoygeDrvr],
        vehicle = snapshot.data()[fieldVoygeVehicle],
        startDate = snapshot.data()[fieldVoygeDepartureDate].toDate(),
        endDate = snapshot.data()[fieldVoygeReturnDate].toDate();
}
