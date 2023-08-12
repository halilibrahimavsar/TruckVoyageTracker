import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hesaplayici/services/database/firestore/constants.dart';

class VehicleModel {
  final String plate;
  final String userId;

  VehicleModel(
    this.plate,
    this.userId,
  );

  VehicleModel.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : plate = snapshot.data()[fieldVhclePlate],
        userId = snapshot.data()[fieldGUserId];
}
