import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';

class FirebaseApi{
  //instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  //function to initialize the notifications
  Future<void> initNotifications() async{
    //request permission from user
    await _firebaseMessaging.requestPermission();
    //fetch the FCM token for this device
    final FCMToken = await _firebaseMessaging.getToken();
    //print the token
    debugPrint('token is :$FCMToken');
  }
}