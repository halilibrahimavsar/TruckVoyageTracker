import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hesaplayici/private_views/main_private.dart';
import 'package:hesaplayici/services/auth/google_signin_provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            return FutureBuilder(
              future: GoogleSignInProvider().isSignedIn(),
              builder: (context, snapshot) {
                switch (snapshot.data) {
                  case true:
                    return FutureBuilder(
                      future: Future.delayed(const Duration(milliseconds: 900)),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.black,
                                color: Colors.purple,
                              ),
                            );
                          case ConnectionState.done:
                            return MainPrivate();
                          default:
                            return const Center(
                              child: Text(
                                  "Something goes wrong. Close aplication and re-open it"),
                            );
                        }
                      },
                    );
                  default:
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text("Giriş Yap"),
                        centerTitle: true,
                      ),
                      body: Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            UserCredential? userCredential =
                                await GoogleSignInProvider().handleSignIn();
                            if (userCredential != null) {
                              UserCredential userC = userCredential;

                              log("User signed in: ${userC.user?.displayName}");
                            }
                          },
                          child: const Text('Sign in with Google'),
                        ),
                      ),
                    );
                }
              },
            );
        }
      },
    );
  }
}
