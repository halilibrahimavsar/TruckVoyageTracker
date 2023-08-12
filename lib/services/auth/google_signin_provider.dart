import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserCredential?> handleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuth =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuth.accessToken,
          idToken: googleSignInAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (error) {
      log("Google Sign-In Error: $error");
    }
    return null;
  }

  Future<void> handleSignOut() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut();
    } catch (error) {
      Center(child: Text("Sign Out Error: $error"));
    }
  }

  Future<bool> isSignedIn() {
    return googleSignIn.isSignedIn();
  }

  GoogleSignInAccount? getUserCredentials() {
    return googleSignIn.currentUser;
  }
}
