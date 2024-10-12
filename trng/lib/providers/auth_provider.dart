import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    notifyListeners();
  }

  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // No error
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return 'An unknown error occurred.';
      }
    } catch (e) {
      print('An error occurred: $e');
      return 'An unknown error occurred.';
    }
  }

  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    setUser(userCredential.user);
  }

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('An error occurred during sign out: $e');
    }
    setUser(null);
  }
}