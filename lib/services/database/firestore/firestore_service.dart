import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hesaplayici/models/person_model.dart';
import 'package:hesaplayici/models/place_model.dart';
import 'package:hesaplayici/models/vehicle_model.dart';
import 'package:hesaplayici/models/voyage_model.dart';
import 'package:hesaplayici/services/database/firestore/constants.dart';

class FirestoreService {
  final _vehicle = FirebaseFirestore.instance.collection(vehicleTable);
  final _person = FirebaseFirestore.instance.collection(personTable);
  final _place = FirebaseFirestore.instance.collection(placeTable);
  final _voyage = FirebaseFirestore.instance.collection(voyageTable);

  // create functions
  Future<void> addPerson({required Map<String, dynamic> data}) async {
    await _person.add(data);
  }

  Future<void> addVoyage({required Map<String, dynamic> data}) async {
    await _voyage.add(data);
  }

  Future<void> addVehicle({required Map<String, dynamic> data}) async {
    await _vehicle.add(data);
  }

  Future<void> addPlace({required Map<String, dynamic> data}) async {
    await _place.add(data);
  }

  // delete functions
  Future<void> deletePersonByName({required String name}) async {
    QuerySnapshot querySnapshot =
        await _person.where(fieldPersName, isEqualTo: name).get();

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.delete();
    }
  }

  Future<void> deletePlaceByName({required String placeName}) async {
    QuerySnapshot querySnapshot =
        await _place.where(fieldPlaceName, isEqualTo: placeName).get();

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.delete();
    }
  }

  Future<void> deleteVehicleByName({required String plate}) async {
    QuerySnapshot querySnapshot =
        await _vehicle.where(fieldVhclePlate, isEqualTo: plate).get();

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.delete();
    }
  }
  // Future<void> deletePers({required String id}) async {
  //   await _person.doc(id).delete();
  // }

  Future<void> deleteVoyage({required String id}) async {
    await _voyage.doc(id).delete();
  }

  // Future<void> deleteVehicle({required String id}) async {
  //   await _vehicle.doc(id).delete();
  // }

  // Future<void> deletePlace({required String id}) async {
  //   await _place.doc(id).delete();
  // }

  // update functions

  Future<void> updatePersonByName({
    required String name,
    required Map<String, dynamic> data,
  }) async {
    QuerySnapshot querySnapshot =
        await _person.where(fieldPersName, isEqualTo: name).get();

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.update(data);
    }
  }

  Future<void> updateVehicleByPlate({
    required String plate,
    required Map<String, dynamic> data,
  }) async {
    QuerySnapshot querySnapshot =
        await _vehicle.where(fieldVhclePlate, isEqualTo: plate).get();

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.update(data);
    }
  }

  Future<void> updatePlaceByName({
    required String name,
    required Map<String, dynamic> data,
  }) async {
    QuerySnapshot querySnapshot =
        await _place.where(fieldPlaceName, isEqualTo: name).get();

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference.update(data);
    }
  }
  // Future<void> updatePers(
  //     {required Map<String, dynamic> data, required String id}) async {
  //   await _person.doc(id).update(data);
  // }

  // Future<void> updateVehicle(
  //     {required Map<String, dynamic> data, required String id}) async {
  //   await _vehicle.doc(id).update(data);
  // }

  Future<void> updateVoyage(
      {required Map<String, dynamic> data, required String id}) async {
    await _voyage.doc(id).update(data);
  }

  // Future<void> updatePlace(
  //     {required Map<String, dynamic> data, required String id}) async {
  //   await _place.doc(id).update(data);
  // }

  // read functions
  Stream<Iterable<PersonModel>> getAllPers({required ownerUserId}) {
    final querySnapshot = _person
        .where(fieldGUserId, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => PersonModel.fromSnapshot(doc)));

    return querySnapshot;
  }

  Stream<Iterable<VehicleModel>> getAllVehicle({required ownerUserId}) {
    final querySnapshot = _vehicle
        .where(fieldGUserId, isEqualTo: ownerUserId)
        .snapshots()
        .map(
            (event) => event.docs.map((doc) => VehicleModel.fromSnapshot(doc)));
    return querySnapshot;
  }

  Stream<Iterable<VoyageModel>> getAllVoyage({required ownerUserId}) {
    final querySnapshot = _voyage
        .where(fieldGUserId, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => VoyageModel.fromSnapshot(doc)));
    return querySnapshot;
  }

  Stream<Iterable<PlaceModel>> getAllPlace({required ownerUserId}) {
    final querySnapshot = _place
        .where(fieldGUserId, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => PlaceModel.fromSnapshot(doc)));
    return querySnapshot;
  }

  // read data by filter:
  Stream<Iterable<VoyageModel>> getVoyageByDate({
    required String plate,
    required Timestamp firstDate,
    required Timestamp lastDate,
    required ownerUserId,
  }) {
    final querySnapshot = _voyage
        .where(fieldGUserId, isEqualTo: ownerUserId)
        .where(fieldVoygeVehicle, isEqualTo: plate)
        .where(fieldVoygeDepartureDate, isGreaterThanOrEqualTo: firstDate)
        .where(fieldVoygeDepartureDate, isLessThanOrEqualTo: lastDate)
        .snapshots()
        .map((event) => event.docs.map((doc) => VoyageModel.fromSnapshot(doc)));

    return querySnapshot;
  }
}
