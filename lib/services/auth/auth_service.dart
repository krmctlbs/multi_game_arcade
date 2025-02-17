import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async{
    try{
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch(e){
      throw Exception(e.code);
    }
  }
  Future<UserCredential> signUpWithEmailAndPassword(String email, password) async{
    try{
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      return userCredential;
    } on FirebaseAuthException catch(e){
      throw Exception(e.code);
    }
    }
  Future<void> signOut() async{
    return await FirebaseAuth.instance.signOut();
  }

}