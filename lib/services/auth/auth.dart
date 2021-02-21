import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCustom {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static Future<User> signInAnonymous() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User firebaseUser = result.user;
      return firebaseUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<User> signUp(String email, String pass) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: pass);
      User firebaseUser = result.user;
      if (!firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      }
      return firebaseUser;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<void> signOut() async {
    _auth.signOut();
  }

  static Stream<User> get firebaseUserStream => _auth.userChanges();
}
