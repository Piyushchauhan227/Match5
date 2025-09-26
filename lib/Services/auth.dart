import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<void> signOutFromGoogle() async {
    try {
      //sign out from firebase
      await FirebaseAuth.instance.signOut();
      print("✅ User signed out");
      //sign out from google
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      //user logout from google
      print("successfully logout");
    } catch (e) {
      print("failed to logout ${e.toString()}");
    }
  }

  Future<UserCredential?> signUpWithMatch(
      String email, String pwd, context, name) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pwd);
      await credential.user?.updateDisplayName(name);
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        print("weak password");
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Email already in use")));
      } else if (e.code == 'invalid-email') {
        print("Invalid email format");
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<UserCredential?> loginWithMatch(
      String email, String pwd, context) async {
    try {
      final credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pwd);
      return credentials;
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-credential") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inavlid Email or Password")));
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> signOutFromMatch() async {}
}
