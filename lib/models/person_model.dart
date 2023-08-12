import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hesaplayici/services/database/firestore/constants.dart';

class PersonModel {
  final String name;
  final String userId;

  PersonModel(this.name, this.userId);

  PersonModel.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : name = snapshot.data()[fieldPersName],
        userId = snapshot.data()[fieldGUserId];
}
