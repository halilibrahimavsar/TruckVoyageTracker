import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hesaplayici/private_views/add_data_views/add_or_update_voyage.dart';
import 'package:hesaplayici/private_views/voyage_menu/voyage_menu.dart';
import 'package:hesaplayici/services/auth/google_signin_provider.dart';
import 'package:hesaplayici/utilities/show_custm_dialog.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class MainPrivate extends StatefulWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  MainPrivate({super.key});

  @override
  MainPrivateState createState() => MainPrivateState();
}

class MainPrivateState extends State<MainPrivate> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return AddOrUpdateVoyage(scaffoldContext: context);
                  },
                ));
              },
              icon: const Icon(Icons.add),
            ),
          ],
          title: const Text('Voyage'),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              tileMode: TileMode.clamp,
              transform: GradientRotation(1),
              colors: [
                Color.fromARGB(255, 102, 0, 133),
                Color.fromARGB(255, 0, 7, 100),
                Color.fromARGB(255, 102, 0, 133),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: VoyageMenu(),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: ShapeDecoration(
                  shape: Border.all(),
                ),
                // decoration: BoxDecoration(color: Colors.blue.shade900),
                accountName: Text('${widget.user!.displayName}'),
                accountEmail: Text('${widget.user?.email}'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.user?.providerData[0].photoURL ??
                        "/assets/images/logo.jpg",
                  ),
                ),
              ),
              ListTile(
                textColor: Colors.red,
                title: const Text('Log out'),
                onTap: () {
                  showCustmDialog(
                    context,
                    title: 'Cıkış yap',
                    msg: 'Log out from ${widget.user?.email}',
                    cancelButton: 'VAZGEÇ',
                    confirmButton: 'ÇIKIŞ YAP',
                    cancelButtonColor: Colors.black,
                    confirmButtonColor: Colors.red,
                    // color: Colors.purple,
                    functionWhenCancel: () {},
                    functionWhenConfirm: () {
                      GoogleSignInProvider().handleSignOut();
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
