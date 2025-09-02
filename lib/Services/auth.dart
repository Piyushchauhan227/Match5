import 'package:firebase_core/firebase_core.dart';
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

      //sign out from google
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      //user logout from google
      print("successfully logout");
    } catch (e) {
      print("failed to logout ${e.toString()}");
    }
  }
}
