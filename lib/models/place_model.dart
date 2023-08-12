import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hesaplayici/services/database/firestore/constants.dart';

class PlaceModel {
  final String placeName;
  final String userId;
  final int placePrice;

  PlaceModel(this.placeName, this.placePrice, this.userId);

  PlaceModel.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : placeName = snapshot.data()[fieldPlaceName],
        placePrice = snapshot.data()[fieldPlacePrice],
        userId = snapshot.data()[fieldGUserId];
}
