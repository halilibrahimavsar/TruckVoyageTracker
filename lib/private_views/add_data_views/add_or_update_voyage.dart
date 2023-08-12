import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hesaplayici/private_views/add_data_views/widgets_of_add_data/path/select_path_and_price.dart';
import 'package:hesaplayici/private_views/add_data_views/widgets_of_add_data/select_date.dart';
import 'package:hesaplayici/private_views/add_data_views/widgets_of_add_data/select_driver.dart';
import 'package:hesaplayici/private_views/add_data_views/widgets_of_add_data/select_km.dart';
import 'package:hesaplayici/private_views/add_data_views/widgets_of_add_data/select_vehicle.dart';
import 'package:hesaplayici/services/database/firestore/constants.dart';
import 'package:hesaplayici/services/database/firestore/firestore_service.dart';
import 'package:hesaplayici/utilities/show_custm_dialog.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AddOrUpdateVoyage extends StatefulWidget {
  final BuildContext scaffoldContext;
  final Map<String, dynamic>? existingData; // Pass existing data if updating

  const AddOrUpdateVoyage(
      {super.key, required this.scaffoldContext, this.existingData});

  @override
  AddOrUpdateVoyageState createState() => AddOrUpdateVoyageState();
}

class AddOrUpdateVoyageState extends State<AddOrUpdateVoyage> {
  final GlobalKey<FormState> _validateData = GlobalKey<FormState>();

  late int departureKm;
  late int returnKm;
  late String wherItVoyage;
  late int price;
  late String driver;
  late String vehicle;
  late DateTime departureDate;
  late DateTime returnDate;
  late int totalKm; // this wont be saved into database
  late String id;

  @override
  void initState() {
    if (widget.existingData != null) {
      // update existing data
      departureKm = int.parse(widget.existingData![fieldVoygeStartkm]);
      returnKm = int.parse(widget.existingData![fieldVoygeEndKm]);
      wherItVoyage = widget.existingData![fieldVoygePlace];
      price = int.parse(widget.existingData![fieldVoygePrice]);
      driver = widget.existingData![fieldVoygeDrvr];
      vehicle = widget.existingData![fieldVoygeVehicle];
      departureDate = widget.existingData![fieldVoygeDepartureDate];
      returnDate = widget.existingData![fieldVoygeReturnDate];
      id = widget.existingData![fieldVoygeId];
      totalKm = returnKm - departureKm;
    } else {
      // add new data
      departureKm = 0;
      returnKm = 0;
      wherItVoyage = '';
      price = 0;
      driver = '';
      vehicle = '';
      departureDate = DateTime.now();
      returnDate = DateTime.now();
      totalKm = 0;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Form(
          key: _validateData,
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back_ios_new, size: 32),
                      ),
                      (widget.existingData != null)
                          ? TextButton(
                              onPressed: () {
                                _update(updateId: id);
                              },
                              child: const Text('Update'),
                            )
                          : TextButton(
                              onPressed: () {
                                _add();
                              },
                              child: const Text('Save'),
                            ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SelectKmWidget(
                          endKm: returnKm.toString(),
                          startKm: departureKm.toString(),
                          sendDataToParent: (firstKm, lastKm, ttlKm) {
                            setState(() {
                              departureKm = firstKm;
                              returnKm = lastKm;
                              totalKm = ttlKm;
                            });
                          },
                        ),
                        SelectPath(
                          sendDataToParent: (String slctdVal, int prce) {
                            setState(() {
                              wherItVoyage = slctdVal;
                              price = prce;
                            });
                          },
                        ),
                        SelectDriverWidget(
                          scaffoldContext: widget.scaffoldContext,
                          sendDataToParent: (String slctedDrvr) {
                            setState(() {
                              driver = slctedDrvr;
                            });
                          },
                        ),
                        SelectVehicleWidget(
                          scaffoldContext: widget.scaffoldContext,
                          sendDataToParent: (String selectVehicle) {
                            setState(() {
                              vehicle = selectVehicle;
                            });
                          },
                        ),
                        SelectDateWidget(
                          sendDatesToParent: (departureD, returnD) {
                            setState(() {
                              departureDate = departureD;
                              returnDate = returnD;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validate() {
    bool result = true;
    if ((driver.isEmpty) ||
        (vehicle.isEmpty) ||
        (returnKm <= 0) ||
        (departureKm <= 0)) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message: 'There should be not empty field!',
        ),
      );
      result = false;
    } else if (departureDate.isAfter(returnDate)) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message: 'departure date is after return date',
        ),
      );
      result = false;
    } else if (departureKm >= returnKm) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.info(
          message: 'start km is bigger than or equals to end km',
        ),
      );
      result = false;
    }
    return result;
  }

  void _update({required String updateId}) {
    if (_validate()) {
      {
        final dialogMsg = '''
        Departure Date: ${DateFormat.yMd().add_Hm().format(departureDate)}
        Return Date: ${DateFormat.yMd().add_Hm().format(returnDate)}
        Start Kilometer: $departureKm
        End Kilometer: $returnKm
        Total Kilometer: $totalKm
        Driver: $driver
        Vehicle: $vehicle
        Where its voyage: $wherItVoyage
        Price: $price
      ''';

        // Show confirmation dialog or perform save operation
        showCustmDialog(
          context,
          title: 'Do you want to update this voyage?',
          msg: dialogMsg,
          cancelButton: "Exit",
          confirmButton: 'Update',
          cancelButtonColor: Colors.black,
          confirmButtonColor: Colors.green,
          functionWhenConfirm: () {
            FirestoreService().updateVoyage(
              id: updateId,
              data: {
                fieldVoygeStartkm: departureKm,
                fieldVoygeEndKm: returnKm,
                fieldVoygePlace: wherItVoyage,
                fieldVoygePrice: price,
                fieldVoygeDrvr: driver,
                fieldVoygeVehicle: vehicle,
                fieldVoygeDepartureDate: Timestamp.fromDate(departureDate),
                fieldVoygeReturnDate: Timestamp.fromDate(returnDate),
                fieldGUserId: FirebaseAuth.instance.currentUser?.uid,
              },
            );

            Navigator.of(context).pop();
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: "Added new voyage",
              ),
            );
          },
          functionWhenCancel: () {},
        );
      }
    }
  }

  void _add() {
    if (_validate()) {
      {
        final dialogMsg = '''
        Departure Date: ${DateFormat.yMd().add_Hm().format(departureDate)}
        Return Date: ${DateFormat.yMd().add_Hm().format(returnDate)}
        Start Kilometer: $departureKm
        End Kilometer: $returnKm
        Total Kilometer: $totalKm
        Driver: $driver
        Vehicle: $vehicle
        Where its voyage: $wherItVoyage
        Price: $price
      ''';

        // Show confirmation dialog or perform save operation
        showCustmDialog(
          context,
          title: 'Do you want to add this voyage?',
          msg: dialogMsg,
          cancelButton: "Exit",
          confirmButton: 'Add',
          cancelButtonColor: Colors.black,
          confirmButtonColor: Colors.green,
          functionWhenConfirm: () {
            FirestoreService().addVoyage(
              data: {
                fieldVoygeStartkm: departureKm,
                fieldVoygeEndKm: returnKm,
                fieldVoygePlace: wherItVoyage,
                fieldVoygePrice: price,
                fieldVoygeDrvr: driver,
                fieldVoygeVehicle: vehicle,
                fieldVoygeDepartureDate: Timestamp.fromDate(departureDate),
                fieldVoygeReturnDate: Timestamp.fromDate(returnDate),
                fieldGUserId: FirebaseAuth.instance.currentUser?.uid,
              },
            );

            Navigator.of(context).pop();
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message: "Added new voyage",
              ),
            );
          },
          functionWhenCancel: () {},
        );
      }
    }
  }
}
