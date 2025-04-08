import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hesaplayici/private_views/add_data_views/widgets_of_add_data/add_rm_person_view/add_person.dart';
import 'package:hesaplayici/private_views/add_data_views/widgets_of_add_data/add_rm_person_view/remove_person.dart';
import 'package:hesaplayici/private_views/add_data_views/widgets_of_add_data/pull_persons.dart';
import 'package:hesaplayici/services/database/firestore/firestore_service.dart';
import 'package:hesaplayici/utilities/glass_effect.dart';

class SelectDriverWidget extends StatefulWidget {
  final Function(String selectedDriverId) sendDataToParent;

  final BuildContext scaffoldContext;

  const SelectDriverWidget(
      {super.key,
      required this.scaffoldContext,
      required this.sendDataToParent});

  @override
  SelectDriverWidgetState createState() => SelectDriverWidgetState();
}

class SelectDriverWidgetState extends State<SelectDriverWidget> {
  String selectedDriverId = "";
  @override
  Widget build(BuildContext context) {
    return GlassEffect(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AddPersonToFrbse(scaffoldContext: widget.scaffoldContext),
          PullPersons(
            stream: FirestoreService().getAllPers(
              ownerUserId: FirebaseAuth.instance.currentUser?.uid,
            ),
            sendDataToParent: (driverId) {
              setState(() {
                selectedDriverId = driverId;
                widget.sendDataToParent(selectedDriverId);
              });
            },
          ),
          RemovePersonFrmFrbse(scaffoldContext: widget.scaffoldContext),
        ],
      ),
    );
  }
}
