import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hesaplayici/private_views/add_data_views/widgets_of_add_data/pull_persons.dart';
import 'package:hesaplayici/services/database/firestore/firestore_service.dart';

class RemovePersonFrmFrbse extends StatefulWidget {
  final BuildContext scaffoldContext;

  const RemovePersonFrmFrbse({super.key, required this.scaffoldContext});

  @override
  State<RemovePersonFrmFrbse> createState() => _RemovePersonFrmFrbseState();
}

class _RemovePersonFrmFrbseState extends State<RemovePersonFrmFrbse> {
  String? selectedPerson;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          isScrollControlled: true,
          isDismissible: true,
          showDragHandle: true,
          context: widget.scaffoldContext,
          builder: (context) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: Column(
                  children: [
                    const Text(
                      'Remove a Person',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 16,
                      width: double.maxFinite,
                    ),
                    PullPersons(
                      stream: FirestoreService().getAllPers(
                          ownerUserId: FirebaseAuth.instance.currentUser?.uid),
                      sendDataToParent: (selectedDriver) {
                        setState(() {
                          selectedPerson = selectedDriver;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          FirestoreService()
                              .deletePersonByName(name: selectedPerson!);
                          selectedPerson = null;
                        });
                      },
                      child: const Text('Remove'),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
      icon: const Icon(
        Icons.remove,
        color: Colors.red,
      ),
    );
  }
}
