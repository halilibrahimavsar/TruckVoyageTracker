import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hesaplayici/services/database/firestore/constants.dart';
import 'package:hesaplayici/services/database/firestore/firestore_service.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AddPersonToFrbse extends StatefulWidget {
  final BuildContext scaffoldContext;

  const AddPersonToFrbse({super.key, required this.scaffoldContext});

  @override
  State<AddPersonToFrbse> createState() => _AddPersonToFrbseState();
}

class _AddPersonToFrbseState extends State<AddPersonToFrbse> {
  String nameAndSurname = '';

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
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
                      'Yeni sürücü ekle',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'İsim ve Soyisim'),
                      onChanged: (value) {
                        setState(() {
                          nameAndSurname = value.toUpperCase();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        // prevent duplication
                        bool isDuplicate =
                            await isThereSamePers(nameAndSurname);

                        if (context.mounted) {
                          if (isDuplicate) {
                            showTopSnackBar(
                              Overlay.of(context),
                              const CustomSnackBar.error(
                                message: "Bu kişi zaten ekli!",
                              ),
                            );
                          } else {
                            FirestoreService().addPerson(
                              data: {
                                fieldGUserId:
                                    FirebaseAuth.instance.currentUser!.uid,
                                fieldPersName: nameAndSurname,
                              },
                            );
                            if (context.mounted) {
                              Navigator.pop(
                                  context); // Close the bottom sheet after saving
                            }
                          }
                        }
                      },
                      child: const Text('Kaydet'),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
      icon: const Icon(
        Icons.add,
        color: Colors.green,
      ),
    );
  }

  Future<bool> isThereSamePers(String name) async {
    final allData = await FirestoreService()
        .getAllPers(
          ownerUserId: FirebaseAuth.instance.currentUser?.uid,
        )
        .first; // Fetch the first result from the stream

    bool isDuplicate = false;
    for (var element in allData) {
      if (element.name == name) {
        isDuplicate = true;
        break;
      }
    }

    return isDuplicate;
  }
}
